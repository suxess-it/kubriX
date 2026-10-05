#!/usr/bin/env bash
# Temporary CI collector. Start before bootstrap; stop its process group before cleanup.
set -uo pipefail
out="${1:-openbao-diagnosis}"
mkdir -p "$out"
started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
trap 'exit 0' TERM INT

# CRDs do not exist at bootstrap start. Reconnect after errors/timeouts and
# record the initial list as well as every subsequent watch event.
watch_resource() {
  local resource=$1 file=$2
  while true; do
    kubectl get "$resource" -A --watch --output-watch-events -o json \
      --request-timeout=60s 2>>"$out/watch-errors.log" |
      jq --unbuffered -c '{observedAt:(now|todateiso8601), type,
        object:(.object | {apiVersion,kind,
          metadata:(.metadata | {name,namespace,uid,resourceVersion,generation,
            creationTimestamp,deletionTimestamp,finalizers,ownerReferences,
            annotations:((.annotations // {}) | with_entries(select(
              .key | startswith("crossplane.io/") or startswith("argocd.argoproj.io/")))),
            managedFields}), status,reason,message,involvedObject,count,
          firstTimestamp,lastTimestamp,
          identity:(if .kind == "Group" then
            {name:.spec.forProvider.name,type:.spec.forProvider.type,
             providerConfigRef:.spec.providerConfigRef} else null end)})}' >>"$out/$file"
    sleep 2
  done
}

watch_resource groups.identity.vault.upbound.io groups.jsonl &
watch_resource applications.argoproj.io applications.jsonl &
watch_resource events events.jsonl &

# Discover each container as it starts, including replacement pods/restarts.
# Full logs are protected by the workflow's encrypted artifact, never echoed.
declare -A followed=()
while true; do
  for ns in crossplane openbao argocd; do
    pods=$(kubectl get pods -n "$ns" -o json --request-timeout=10s 2>>"$out/watch-errors.log") || continue
    jq -c --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '.items[] | {observedAt:$at,metadata:(.metadata | {name,namespace,uid}),
        status:(.status | {phase,conditions,containerStatuses,initContainerStatuses})}' \
      <<<"$pods" >>"$out/pods.jsonl"
    while IFS=$'\t' read -r pod uid container restarts; do
      [[ -n "$pod" ]] || continue
      key="$ns-$uid-$container-$restarts"
      [[ -z "${followed[$key]:-}" ]] || continue
      followed[$key]=1
      kubectl logs -n "$ns" "$pod" -c "$container" --follow --timestamps \
        --since-time="$started" >"$out/$ns-$pod-$container-$restarts.log" 2>&1 &
      if (( restarts > 0 )); then
        kubectl logs -n "$ns" "$pod" -c "$container" --previous --timestamps \
          --request-timeout=10s >"$out/$ns-$pod-$container-$restarts-previous.log" 2>&1 &
      fi
    done < <(jq -r '.items[] as $pod |
      (($pod.status.containerStatuses // []) + ($pod.status.initContainerStatuses // []))[] |
      select(.state.running != null or .state.terminated != null) |
      [$pod.metadata.name,$pod.metadata.uid,.name,.restartCount] | @tsv' <<<"$pods")
  done
  sleep 5
done
