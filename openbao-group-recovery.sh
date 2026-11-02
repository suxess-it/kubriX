#!/usr/bin/env bash
# Shared installer/CI workaround for https://github.com/crossplane/upjet/pull/782.
# Caller owns the associative array openbao_adopted_groups for one recovery session.

read_openbao_group_for_recovery() (
  # Never expose credentials through installer xtrace, arguments, or errors.
  set +x
  local id="$1" token pod
  token="$(timeout 10s kubectl get secret crossplane-init -n openbao -o jsonpath='{.data.credentials}' 2>/dev/null \
    | base64 -d | jq -er '.token | select(type == "string" and length > 0)')" || return 1
  pod="$(timeout 10s kubectl get endpoints sx-openbao-active -n openbao \
    -o jsonpath='{.subsets[0].addresses[0].targetRef.name}' 2>/dev/null)" || return 1
  [[ -n "$pod" ]] || return 1
  printf '%s' "$token" | timeout 10s kubectl exec -i -n openbao "$pod" -c openbao -- sh -c '
    export VAULT_TOKEN="$(cat)"
    export VAULT_ADDR=http://127.0.0.1:8200 VAULT_NAMESPACE=kubrix
    exec bao read -format=json "identity/group/id/$1"
  ' sh "$id" 2>/dev/null
)

# Returns success while an adopted group is awaiting Crossplane readiness.
# State is scoped to the current installer wait, keyed by Kubernetes UID.
recover_openbao_groups() {
  local app="${1:-sx-openbao}"
  local groups group name uid id existing patch pending=false
  [[ "$app" == sx-openbao || "$app" == sx-team-onboarding ]] || return 1
  if ! groups="$(timeout 10s kubectl get groups.identity.vault.upbound.io -o json 2>/dev/null)"; then
    # A transient API failure must not release the hook-retry interlock.
    [[ " ${openbao_adopted_groups[*]} " == *" pending "* ]]
    return
  fi
  while IFS= read -r group; do
    name="$(jq -r '.metadata.name' <<<"$group")"
    uid="$(jq -r '.metadata.uid' <<<"$group")"
    if [[ -n "${openbao_adopted_groups[$uid]:-}" ]]; then
      if jq -e 'any(.status.conditions[]?; .type == "Ready" and .status == "True")' >/dev/null <<<"$group"; then
        if [[ "${openbao_adopted_groups[$uid]}" != ready ]]; then
          echo "[openbao-recovery] group=$name result=ready"
          openbao_adopted_groups[$uid]=ready
        fi
      else
        pending=true
      fi
      continue
    fi
    id="$(jq -r '
      .metadata.name as $name
      | if (.metadata.annotations["crossplane.io/external-name"] // "") != ""
          or any(.status.conditions[]?; .type == "Ready" and .status == "True") then empty
        else [.status.conditions[]? | select(.status == "False") | .message // ""
          | try capture("failed to create identity group \"(?<name>[a-z0-9][a-z0-9-]*)\", reason=group already exists with path=\"/identity/group/name/(?<path>[a-z0-9][a-z0-9-]*)\", id=\"(?<id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}([.][A-Za-z0-9_-]+)?)\"") catch empty
          | select(.name == $name and .path == $name) | .id] | unique | if length == 1 then .[0] else empty end
        end' <<<"$group")" || continue
    [[ -n "$id" ]] || continue
    if ! existing="$(read_openbao_group_for_recovery "$id")" \
       || ! jq -e --arg id "$id" --arg name "$name" \
         '.data.id == $id and .data.name == $name and .data.type == "external"' >/dev/null <<<"$existing"; then
      echo "[openbao-recovery] group=$name action=deferred reason=identity-not-verified"
      continue
    fi
    # Protect the missing-annotation check and preserve all other annotations.
    patch="$(jq -c --arg id "$id" '[
      {op:"test", path:"/metadata/uid", value:.metadata.uid},
      {op:"test", path:"/metadata/resourceVersion", value:.metadata.resourceVersion},
      {op:"add", path:"/metadata/annotations", value:((.metadata.annotations // {}) + {"crossplane.io/external-name":$id})}
    ]' <<<"$group")"
    if timeout 10s kubectl patch groups.identity.vault.upbound.io "$name" --type=json -p "$patch" >/dev/null 2>&1; then
      openbao_adopted_groups[$uid]=pending
      pending=true
      echo "[openbao-recovery] group=$name action=adopt-existing-group result=waiting-for-ready"
    else
      echo "[openbao-recovery] group=$name action=deferred reason=resource-changed-or-patch-failed"
    fi
  done < <(jq -c --arg app "$app" '.items[]? | select(
    (if $app == "sx-openbao" then
      (.metadata.name == "admins" or .metadata.name == "editors" or .metadata.name == "viewers")
    else
      ((.metadata.annotations["argocd.argoproj.io/tracking-id"] // "")
        == ("sx-team-onboarding:identity.vault.upbound.io/Group:argocd/" + .metadata.name))
    end)
    and (.metadata.namespace // "") == ""
    and .metadata.deletionTimestamp == null
    and .spec.providerConfigRef.name == "openbao-crossplane-providerconfig"
    and .spec.forProvider.name == .metadata.name and .spec.forProvider.type == "external"
  )' <<<"$groups")
  [[ "$pending" == true ]]
}

