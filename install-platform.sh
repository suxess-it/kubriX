#!/usr/bin/env bash

# Safer prologue
set -Eeuo pipefail

# Debug if requested
if [[ "${KUBRIX_INSTALL_DEBUG:-}" == "true" ]]; then set -x; fi

# Simple error trap
fail() { printf '%s\n' "$1" >&2; exit "${2:-1}"; }
trap 'fail "Error on line $LINENO"' ERR

check_tool() {
  tool=$1
  command=$2
  version_output="${3-}"
  version=$( ${command} ) || fail "prereq check failed: ${tool} not found"
  echo "${tool} found with version '${version}'"
}

check_variable() {
  variable=$1
  show_output=$2
  sane_default="${3:-}"
  # check if variable is set
  if [ -z "${!variable:-}" ]; then
    # set variable to a sane default if a sane default is present, else exit with error
    if [ ! -z "${sane_default}" ]; then
      printf -v "${variable}" '%s' "${sane_default}"
      if [ ${show_output} = "true" ] ; then
        echo "set ${variable} to sane default '${!variable}'"
      else
        echo "set ${variable} to sane default. Value is a secret."
      fi
    else
      fail "prereq check failed: variable '${variable}' is blank or not set"
    fi
  # show value of the variable, unless show_output is false (for omitting output of secrets)
  elif [ ${show_output} = "true" ] ; then
    echo "${variable} is set to '${!variable}'"
  else
    echo "${variable} is set. Value is a secret."
  fi
}

check_prereqs() {
  echo ""
  echo "Checking prereqs ..."
  echo "arch: ${ARCH}"
  echo "os: ${OS}"

  # check variables
  check_variable KUBRIX_REPO "true"
  check_variable KUBRIX_REPO_BRANCH "true" "main"
  check_variable KUBRIX_REPO_USERNAME "true" "dummy"
  check_variable KUBRIX_REPO_PASSWORD "false"
  check_variable KUBRIX_BACKSTAGE_GITHUB_TOKEN "false" "${KUBRIX_REPO_PASSWORD}"
  check_variable KUBRIX_TARGET_TYPE "true" "kubrix-oss-stack"
  check_variable KUBRIX_CLUSTER_TYPE "true" "k8s"
  check_variable KUBRIX_BOOTSTRAP_MAX_WAIT_TIME "true" "2400"
  check_variable KUBRIX_INSTALLER "true" "false"
  check_variable KUBRIX_GENERATE_SECRETS "true" "true"
  check_variable KUBRIX_GIT_USER_NAME "true" "dummy"
  check_variable KUBRIX_METALLB_IP "true" " "

  # if bootstrapping from kubriX upstream to empty customer repo is set to true
  check_variable KUBRIX_BOOTSTRAP "true" "false"

  if [ "${KUBRIX_BOOTSTRAP}" = "true" ] ; then
    check_variable KUBRIX_BOOTSTRAP_KEEP_HISTORY "true" "false"
    check_variable KUBRIX_UPSTREAM_REPO "true" "https://github.com/suxess-it/kubriX"
    check_variable KUBRIX_UPSTREAM_BRANCH "true" "main"
    check_variable KUBRIX_UPSTREAM_REPO_USERNAME "true" "dummy"
    check_variable KUBRIX_UPSTREAM_REPO_PASSWORD "false" " "
    check_variable KUBRIX_DOMAIN "true" "demo-$(printf '%s' "${KUBRIX_REPO}" | sha256_portable | head -c 10).kubrix.cloud"
    check_variable KUBRIX_DNS_PROVIDER "true" "ionos"
    check_variable KUBRIX_CLOUD_PROVIDER "true" "on-prem"
    check_variable KUBRIX_TSHIRT_SIZE "true" "small"
    check_variable KUBRIX_SECURITY_STRICT "true" "false"
    check_variable KUBRIX_HA_ENABLED "true" "false"
    check_variable KUBRIX_CERT_MANAGER_DNS_PROVIDER "true" "none"
    check_tool gomplate "gomplate -v"
  fi

  # check tools
  check_tool yq "yq --version"
  check_tool jq "jq --version"
  check_tool kubectl "kubectl version --client=true"
  check_tool helm "helm version"
  check_tool curl "curl -V | head -1"
  check_tool k8sgpt "k8sgpt version"
  
  if [[ "${KUBRIX_CLUSTER_TYPE}" == "kind" ]] ; then
    check_tool mkcert "mkcert --version"
  fi

  echo "Prereq checks finished sucessfully."
  echo ""
}

detect_date_impl() {
  if "$DATE_BIN" --version >/dev/null 2>&1; then echo gnu; return; fi
  if "$DATE_BIN" -d @0 +%s >/dev/null 2>&1; then echo gnu; return; fi
  if "$DATE_BIN" -r 0 +%s >/dev/null 2>&1; then echo bsd; return; fi
  if "$DATE_BIN" -v -1d +%s >/dev/null 2>&1; then echo bsd; return; fi
  echo unknown
}

# clone kubriX upstream repo to bootstrap-kubriX/kubriX-repo
bootstrap_clone_from_upstream() {
  printf 'bootstrap from upstream repo %s to downstream repo %s' "${KUBRIX_UPSTREAM_REPO}" "${KUBRIX_REPO}\n"
  printf 'checkout kubriX upstream to %s ...\n' "$(pwd)"

  if [ "${KUBRIX_UPSTREAM_REPO_PASSWORD}" != " " ]; then
    # get protocol and url of the kubrix repo for bootstrap templating and repo cloning
    KUBRIX_UPSTREAM_REPO_PROTO=$(echo ${KUBRIX_UPSTREAM_REPO} | grep :// | sed "s,^\(.*://\).*,\1,")
    # remove the protocol from url
    KUBRIX_UPSTREAM_REPO_URL=$(echo ${KUBRIX_UPSTREAM_REPO} | sed "s,^${KUBRIX_REPO_PROTO},,")
    git clone ${KUBRIX_UPSTREAM_REPO_PROTO}${KUBRIX_UPSTREAM_REPO_USERNAME}:${KUBRIX_UPSTREAM_REPO_PASSWORD}@${KUBRIX_UPSTREAM_REPO_URL} .
  else
    git clone ${KUBRIX_UPSTREAM_REPO} .
  fi
  
  git checkout "${KUBRIX_UPSTREAM_BRANCH}"

  git config user.name "kubrix-installer[kubrix-bot]"
  git config user.email "kubrix-installer[kubrix-bot]@users.noreply.github.com"

  if [ "${KUBRIX_BOOTSTRAP_KEEP_HISTORY}" != "true" ]; then
    # Create an orphan branch that has NO parents
    # just for demo purposes to hide commit history, for official customer projects it might be a disadvantage for merging to updates.
    # need to test that
    git checkout --orphan publish
  fi
}

bootstrap_template_downstream_repo() {
  # get git server organization (for backstage scaffolder templates)
  KUBRIX_REPO_ORG=$(echo $KUBRIX_REPO_URL | awk -F/ '{print $2}')
  # get name of the repo
  KUBRIX_REPO_NAME=$(echo $KUBRIX_REPO_URL | awk -F/ '{print $3}')
  # remove .git suffix if it exists
  KUBRIX_REPO_NAME=${KUBRIX_REPO_NAME%".git"}

# write new customer values in customer config (without indentation because of heredoc)
cat << EOF > bootstrap/customer-config.yaml
clusterType: ${KUBRIX_CLUSTER_TYPE}
cloudProvider: ${KUBRIX_CLOUD_PROVIDER}
dnsProvider: ${KUBRIX_DNS_PROVIDER}
certManagerDnsProvider: ${KUBRIX_CERT_MANAGER_DNS_PROVIDER}
tShirtSize: ${KUBRIX_TSHIRT_SIZE}
securityStrict: ${KUBRIX_SECURITY_STRICT}
haEnabled: ${KUBRIX_HA_ENABLED}
domain: ${KUBRIX_DOMAIN}
gitRepo: ${KUBRIX_REPO}
gitRepoOrg: ${KUBRIX_REPO_ORG}
gitRepoName: ${KUBRIX_REPO_NAME}
gitUser: ${KUBRIX_GIT_USER_NAME}
metalLbIp: ${KUBRIX_METALLB_IP}
EOF

  echo "the current customer-config is like this:"
  echo "----"
  cat bootstrap/customer-config.yaml
  echo "----"

  echo "rendering values templates ..."
  gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir platform-apps --include *.yaml.tmpl --output-map='platform-apps/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
  gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir backstage-resources --include *.yaml.tmpl --output-map='backstage-resources/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
  gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir docs --include *.md.tmpl --output-map='docs/{{ .in | strings.ReplaceAll ".md.tmpl" ".md" }}'

  # exclude apps from KUBRIX_APP_EXCLUDE
  if [[ -n "${KUBRIX_APP_EXCLUDE:-}" ]]; then
    echo "exclude apps $KUBRIX_APP_EXCLUDE from platform-apps/target-chart/values-${KUBRIX_TARGET_TYPE}.yaml"
    yq e '((env(KUBRIX_APP_EXCLUDE) // "") | split(" ") | map(select(length>0))) as $ex | .applications |= map(. as $a | select(($ex | contains([$a.name])) | not))' -i platform-apps/target-chart/values-${KUBRIX_TARGET_TYPE}.yaml
  fi

}

bootstrap_push_to_downstream() {
  echo "Push kubriX gitops files to ${KUBRIX_REPO}"
  git remote add customer ${KUBRIX_REPO_PROTO}${KUBRIX_REPO_PASSWORD}@${KUBRIX_REPO_URL}
  git add -A
  git commit -a -m "add customer specific modifications during bootstrap"

  if [ "${KUBRIX_BOOTSTRAP_KEEP_HISTORY}" != "true" ]; then
    git push --set-upstream customer publish:main
  else
    git push --set-upstream customer ${KUBRIX_UPSTREAM_BRANCH}:main
  fi
}

# Current UTC epoch seconds (works on GNU & BSD)
utc_now_seconds() {
  "$DATE_BIN" -u +%s
}

# Convert ISO8601 → epoch seconds.
# Accepts: 2025-08-11T10:20:30 with optional .sss and TZ (Z, +HH:MM, +HHMM)
convert_to_seconds() {
  local ts="$1"
  case "$DATE_IMPL" in
    gnu)
      if [[ "$ts" =~ (Z|z|[+-][0-9]{2}(:?[0-9]{2})?)$ ]]; then
        "$DATE_BIN" -d "$ts" +%s
      else
        "$DATE_BIN" -u -d "$ts" +%s
      fi
      ;;
    bsd)
      local base="${ts%%.*}" fmt="%Y-%m-%dT%H:%M:%S"
      if [[ "$base" =~ [Zz]$ ]]; then
        base="${base%Z}${base%z}+0000"; fmt="$fmt%z"
      elif [[ "$base" =~ [+-][0-9]{2}:[0-9]{2}$ ]]; then
        base="${base:0:${#base}-3}${base: -2}"; fmt="$fmt%z"
      elif [[ "$base" =~ [+-][0-9]{4}$ ]]; then
        fmt="$fmt%z"
      else
        TZ=UTC "$DATE_BIN" -j -f "$fmt" "$base" +%s; return
      fi
      TZ=UTC "$DATE_BIN" -j -f "$fmt" "$base" +%s
      ;;
    *)
      echo "Unknown date(1) implementation" >&2; return 1
      ;;
  esac
}

lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]';
}

detect_os() {
  local s; s="$(uname -s 2>/dev/null || echo unknown)"
  case "$(lower "$s")" in
    linux*)  echo linux ;;
    darwin*) echo darwin ;;
    msys*|mingw*|cygwin*) echo windows ;;
    *) echo unknown ;;
  esac
}

detect_arch() {
  local m; m="$(uname -m 2>/dev/null || echo unknown)"
  case "$m" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    armv7l|armv7) echo armv7 ;;
    armv6l|armv6) echo armv6 ;;
    i386|i686)    echo 386 ;;
    *) echo unknown ;;
  esac
}

sha256_portable() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

create_vault_secrets_for_backstage() {
  echo "adding special configuration for sx-backstage"

  # create an empty codespaces-secret secret because it is still needed for github codespaces and cannot configured optional in backstage
  kubectl create secret generic -n backstage codespaces-secret --dry-run=client -o yaml | kubectl apply -f -

  # get vault hostname and token for communicating with vault via curl
  export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
  export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)

  # set vault address and vault internal address so backstage can communicate with vault
  curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request POST --data "{\"data\": {\"VAULT_ADDR\": \"https://${VAULT_HOSTNAME}\", \"VAULT_ADDR_INT\": \"http://sx-vault-active.vault.svc.cluster.local:8200\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/security/vault/base

  # store env variable KUBRIX_BACKSTAGE_GITHUB_TOKEN in vault
  curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request PATCH --header "Content-Type: application/merge-patch+json" --data "{\"data\": {\"GITHUB_TOKEN\": \"${KUBRIX_BACKSTAGE_GITHUB_TOKEN}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base

  # generate argocd token and store in vault
  export ARGOCD_AUTH_TOKEN="$( kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd account generate-token --account backstage --core )"
  curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request PATCH --header "Content-Type: application/merge-patch+json" --data "{\"data\": {\"ARGOCD_AUTH_TOKEN\": \"${ARGOCD_AUTH_TOKEN}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base

  # generate grafana token if grafana ingress is found and store in vault
  export GRAFANA_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n grafana )  
  if [ "${GRAFANA_HOSTNAME}" != "" ]; then
    # check if the grafana user/admin is stored in secret, or use default credentials
    if kubectl get secret grafana-admin-secret -n grafana &>/dev/null; then
      export GRAFANA_USER=$(kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey }'  | base64 -d)
      export GRAFANA_PASSWORD=$(kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey }'  | base64 -d)
    else
      # use default credentials
      export GRAFANA_USER="admin"
      export GRAFANA_PASSWORD="prom-operator"
    fi

    ID=$( curl -k -X POST https://${GRAFANA_HOSTNAME}/api/serviceaccounts --user "${GRAFANA_USER}:${GRAFANA_PASSWORD}" -H "Content-Type: application/json" -d '{"name": "backstage","role": "Viewer","isDisabled": false}' | jq -r .id )
    export GRAFANA_TOKEN=$(curl -k -X POST https://${GRAFANA_HOSTNAME}/api/serviceaccounts/${ID}/tokens --user "${GRAFANA_USER}:${GRAFANA_PASSWORD}" -H "Content-Type: application/json" -d '{"name": "backstage"}' | jq -r .key)
  else
    export GRAFANA_TOKEN="dummy"
  fi
  curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request PATCH --header "Content-Type: application/merge-patch+json" --data "{\"data\": {\"GRAFANA_TOKEN\": \"${GRAFANA_TOKEN}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base

}

wait_until_apps_synced_healthy() {
  local apps=$1
  local synced=$2
  local healthy=$3
  local max_wait_time=$4

  echo "wait until these apps have reached sync state '${synced}' and health state '${healthy}'"
  echo "apps: ${apps}"
  echo "max wait time: ${max_wait_time}"

  start=$SECONDS
  end=$((SECONDS+${max_wait_time}))

  k8smonitoring_restarted=false

  while [ $SECONDS -lt $end ]; do
    all_apps_synced="true"

    # check if sx-boostrap-app already failed and restart sync
    bootstrap_app="sx-bootstrap-app"
    operation_state_bootstrap_app=$(kubectl get application -n argocd ${bootstrap_app} -o jsonpath='{.status.operationState}')
    if [ "${operation_state_bootstrap_app}" != "" ] ; then
      operation_phase_bootstrap_app=$(kubectl get application -n argocd ${bootstrap_app} -o jsonpath='{.status.operationState.phase}')
      if [ "${operation_phase_bootstrap_app}" = "Failed" ] || [ "${operation_phase_bootstrap_app}" = "Error" ] ; then
        echo "sx-boostrap-app sync failed. Restarting sync ..."
        kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app terminate-op "$bootstrap_app" --core || true
        kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app sync "$bootstrap_app" --async --core || true
      fi
    fi

    # print app status in beautiful table
    printf 'app sync-status health-status sync-duration operation-phase\n' > status-apps.out

    for app in ${apps} ; do
      if kubectl get application -n argocd ${app} > /dev/null 2>&1 ; then
        sync_status=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.sync.status}')
        health_status=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.health.status}')

        # special case for sx-vault
        if [[ "${app}" == "sx-vault" && "${sync_status}" == "${synced}" && "${health_status}" == "${healthy}" ]]; then
          if [ ! -f ./.secrets/secrettemp/secrets-applied ] && [ ${KUBRIX_GENERATE_SECRETS} = "true" ] ; then
            echo "sx-vault is synced and healthy — applying pushsecrets"
            echo 
            kubectl apply -f ./.secrets/secrettemp/pushsecrets.yaml
            touch ./.secrets/secrettemp/secrets-applied
            echo "--------------------"
          fi
        fi

        # special case for sx-backstage - create vault secrets when backstage is synced.
        # side note: backstage should be able to fully sync,
        #   but will be progressing until the vault secrets exist which we create here
        #   because of externalsecret 'sx-cnp-secret' which waits for these vault secrets
        if [[ "${app}" == "sx-backstage" && "${sync_status}" == "${synced}" ]]; then
          if [ ! -f ./backstage-vault-secrets-created ]; then
            echo "sx-backstage is synced — creating vault secrets"
            echo 
            create_vault_secrets_for_backstage
            touch ./backstage-vault-secrets-created
            echo "--------------------"
          fi
        fi

        # special case for k8s-monitoring to re-sync one time after it deployed sucessfully,
        # because of a .Capabilities.APIVersions.Has condition in the templates for monitoring.coreos which gets deployed by k8s-monitoring itself
        if [[ "${app}" == "sx-k8s-monitoring" && "${sync_status}" == "${synced}" && "${health_status}" == "${healthy}" ]]; then
          if [  "${k8smonitoring_restarted}" != "true" ]; then
            kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app sync "$app" --async --core || true
            k8smonitoring_restarted="true"
          fi
        fi
        
        if [[ "${sync_status}" != ${synced} ]] || [[ "${health_status}" != ${healthy} ]] ; then
          all_apps_synced="false"
        fi


        # check if app sync is stuck and needs to get restarted
        # if app has no resources, operationState is empty
        operation_state=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.operationState}')
        if [ "${operation_state}" != "" ] ; then
          # from our tests this time is always UTC!
          sync_started=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.operationState.startedAt}' |sed 's/Z$//')
          sync_finished=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.operationState.finishedAt}' |sed 's/Z$//')
          sync_started_seconds=$(convert_to_seconds "${sync_started}")

          # if sync finished, duration is 'finished - started', otherwise its 'now - started'
          if [ "${sync_finished}" != "" ] ; then
            sync_finished_seconds=$(convert_to_seconds "${sync_finished}")
            sync_duration=$((${sync_finished_seconds}-${sync_started_seconds}))
          else
            # since '.status.operationState.startedAt' is always UTC (from our tests)
            #  we need to get 'now' also in UTC
            now_seconds=$(utc_now_seconds)
            sync_finished_seconds="-"
            sync_duration=$((${now_seconds}-${sync_started_seconds}))
          fi
          # terminate sync if sync is running and takes longer than 300 seconds (workaround when sync gets stuck)
          operation_phase=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.operationState.phase}')
          if [ "${operation_phase}" = "Running" ] && [ ${sync_duration} -gt 300 ] || [ "${operation_phase}" = "Failed" ] || [ "${operation_phase}" = "Error" ] ; then
            # Terminate the operation for the application
            echo "sync of app ${app} gets terminated because it took longer than 300 seconds or failed"
            kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app terminate-op "$app" --core || true
            echo "wait for 10 seconds"
            sleep 10
            echo "restart sync for app ${app}"
            kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app sync "$app" --async --core || true
          fi
        else
            sync_started_seconds="-"
            sync_finished_seconds="-"
            sync_duration="-"
        fi

        # print app status in beautiful table
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' ${app} ${sync_status} ${health_status} ${sync_duration} ${operation_phase} >> status-apps.out

      else
        printf '%s - - - -\n' ${app} >> status-apps.out
        all_apps_synced="false"	
      fi
    done

    # print app status in beautiful table
    cat status-apps.out | column -t
    rm status-apps.out

    if [ ${all_apps_synced} = "true" ] ; then
      echo "${apps} apps are synced"
      break
    fi

    elapsed_time=$((SECONDS-${start}))
    echo "--------------------"
    echo "elapsed time: ${elapsed_time} seconds"
    echo "max wait time: ${max_wait_time} seconds"
    echo "wait another 10 seconds"
    echo "--------------------"
    sleep 10
  done

  if [ ${all_apps_synced} != "true" ] ; then
    echo "not all apps synced and healthy after limit reached :("
    analyze_all_unhealthy_apps "${apps}"
    exit 1
  else
    echo "all apps are synced."
  fi
}

analyze_all_unhealthy_apps() {
  local apps=$1
  for app in ${apps} ; do
    if kubectl get application -n argocd ${app} > /dev/null 2>&1 ; then
      sync_status=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.sync.status}')
      health_status=$(kubectl get application -n argocd ${app} -o jsonpath='{.status.health.status}')

      if [[ "${sync_status}" != ${synced} ]] || [[ "${health_status}" != ${healthy} ]] ; then
        analyze_app ${app}
      fi
    fi
  done
  echo "===== k8sgpt analyze ====="
  k8sgpt analyze
  echo "===== kubectl describe node ======"
  kubectl describe node
  echo "===== kubectl top node  ======"
  kubectl top node
  echo "===== kubectl get nodes ======"
  kubectl get nodes -o yaml
  echo "===== crossplane managed ======"
  kubectl get managed
  kubectl get managed -o yaml
  kubectl get pkg
  kubectl get pkg -o yaml
}

analyze_app() {
  local app=$1

  # get target namespace for app
  app_namespace=$( kubectl get applications -n argocd ${app} -o=jsonpath='{.spec.destination.namespace}' )

  echo "------------------"
  echo "starting analyzing unhealthy/unsynced app '${app}'"
  echo "------------------"

  # get application spec and status
  echo "------------------"
  echo "kubectl get application -n argocd ${app} -o yaml"
  kubectl get application -n argocd ${app} -o yaml
  echo "------------------"

  echo "------------------"
  echo "argocd app get ${app} --show-operation -o json"
  kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd app get ${app} --show-operation -o json --core
  echo "------------------"

  # get events in this namespace
  echo "------------------"
  echo "kubectl get events -n ${app_namespace} --sort-by='.lastTimestamp'"
  kubectl get events -n ${app_namespace} --sort-by='.lastTimestamp'
  echo "------------------"

  # get pods for app
  echo "------------------"
  echo "kubectl get pods -n ${app_namespace}"
  kubectl get pods -n ${app_namespace}
  echo "------------------"

  # describe pods for app
  echo "------------------"
  echo "kubectl describe pod -n ${app_namespace}"
  kubectl describe pod -n ${app_namespace}
  echo "------------------"

  # get logs
  echo "------------------"
  echo "kubectl get pods -o name -n ${app_namespace} | xargs -I {} kubectl logs -n ${app_namespace} {}"
  kubectl get pods -o name -n ${app_namespace} | xargs -I {} kubectl logs -n ${app_namespace} {} --all-containers=true
  echo "------------------"

  echo "------------------"
  echo "finished analyzing degraded app '${app}'"
  echo "------------------"
}

# exclude apps from a space-separated list
exclude_apps() {
  local apps="$1"
  local exclude_list="$2"
  local filtered=""

  for app in $apps; do
    local skip=false
    for ex in $exclude_list; do
      if [[ "$app" == "sx-$ex" ]]; then
        skip=true
        break
      fi
    done
    $skip || filtered+="$app "
  done

  echo "$filtered"
}

# main starts here

# version from ENV
echo "Version: ${APP_VERSION:-unknown}"
echo "Revision: ${VCS_REF:-unknown}"

# version from file (fallback)
if [ -f /etc/image-version ]; then
  echo "Image metadata:"
  cat /etc/image-version
fi

ARCH="$(detect_arch)"
OS="$(detect_os)"

check_prereqs

# Portable date(1) detection + helpers
if command -v gdate >/dev/null 2>&1; then
  DATE_BIN="$(command -v gdate)"
else
  DATE_BIN="$(command -v date)"
fi
DATE_IMPL="$(detect_date_impl)"

# get protocol and url of the kubrix repo for bootstrap templating and repo cloning
export KUBRIX_REPO_PROTO=$(echo ${KUBRIX_REPO} | grep :// | sed "s,^\(.*://\).*,\1,")
# remove the protocol from url
export KUBRIX_REPO_URL=$(echo ${KUBRIX_REPO} | sed "s,^${KUBRIX_REPO_PROTO},,")

# if KUBRIX_BOOTSTRAP is set to 'true', clone upstream repo, template files, and push to downstream repo
if [ "${KUBRIX_BOOTSTRAP}" = "true" ] ; then
  cd "$HOME"
  if [ -d "bootstrap-kubriX" ]; then
    printf '%s\n' "boostrap-kubriX already exists. We will delete it."
    rm -rf bootstrap-kubriX
  fi
  mkdir -p bootstrap-kubriX/kubriX-repo
  cd bootstrap-kubriX/kubriX-repo
  bootstrap_clone_from_upstream
  bootstrap_template_downstream_repo
  bootstrap_push_to_downstream
fi

# checkout repo when running inside kubrix-installer job
if [ ${KUBRIX_INSTALLER} = "true" ] ; then
  cd "$HOME"
  printf 'checkout kubriX to %s ...\n' "$(pwd)/kubriX"
  mkdir kubriX
  git clone ${KUBRIX_REPO_PROTO}${KUBRIX_REPO_USERNAME}:${KUBRIX_REPO_PASSWORD}@${KUBRIX_REPO_URL} kubriX
  cd kubriX
  git checkout "${KUBRIX_REPO_BRANCH}"
fi

if [[ "${KUBRIX_CLUSTER_TYPE}" == "kind" ]] ; then
  
  # resolv domainname to ingress adress to solve localhost result 
  kubectl get configmap coredns -n kube-system -o yaml |  awk '
/ready/ {
    print;
    print "        rewrite name keycloak.127-0-0-1.nip.io sx-ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name grafana.127-0-0-1.nip.io sx-ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name argocd.127-0-0-1.nip.io sx-ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name vault.127-0-0-1.nip.io sx-ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name backstage.127-0-0-1.nip.io sx-ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    next
}
{ print }
' > coredns-configmap.yaml
  kubectl apply -f coredns-configmap.yaml
  kubectl rollout restart deployment coredns -n kube-system
  rm coredns-configmap.yaml

  # create mkcert-issuer root certificate
  mkcert -install
  kubectl get ns cert-manager >/dev/null 2>&1 || kubectl create ns cert-manager
  kubectl create secret tls mkcert-ca-key-pair --key "$(mkcert -CAROOT)"/rootCA-key.pem --cert "$(mkcert -CAROOT)"/rootCA.pem -n cert-manager --dry-run=client -o yaml | kubectl apply -f -

  # create a cacert secret for backstage so backstage trusts internal services with mkcert certificates
  kubectl get ns backstage >/dev/null 2>&1 || kubectl create ns backstage
  kubectl create secret generic mkcert-cacert --from-file=ca.crt="$(mkcert -CAROOT)"/rootCA.pem -n backstage --dry-run=client -o yaml | kubectl apply -f -

  # vault oidc case
  echo "create a root ca and patch ingress-nginx-controller for vault oidc"
  kubectl get ns vault >/dev/null 2>&1 || kubectl create ns vault
  kubectl create secret generic ca-cert --from-file=ca.crt="$(mkcert -CAROOT)"/rootCA.pem -n vault --dry-run=client -o yaml | kubectl apply -f -

  # testkube should also trust every cert signed with our mkcert ca
  kubectl get ns testkube >/dev/null 2>&1 || kubectl create ns testkube
  kubectl create secret generic ca-cert --from-file=ca.crt="$(mkcert -CAROOT)"/rootCA.pem -n testkube --dry-run=client -o yaml | kubectl apply -f -

  # testkube also needs credentials to retrieve testfiles on the kubriX github repo
  kubectl create secret generic git-credentials --from-literal=username=${KUBRIX_REPO_USERNAME} --from-literal=token=${KUBRIX_REPO_PASSWORD} -n testkube --dry-run=client -o yaml | kubectl apply -f -

  # curl should trust all websites with the mkcert cert
  export CURL_CA_BUNDLE="$(mkcert -CAROOT)"/rootCA-key.pem

  echo "installing metrics-server in KinD"
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm repo update
  helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system
fi

# create argocd with helm chart not with install.yaml
# because afterwards argocd is also managed by itself with the helm-chart

# install argocd unless it is already deployed
echo "installing bootstrap argocd ..."
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install sx-argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version 8.5.2 \
  --namespace argocd \
  --create-namespace \
  --set configs.cm.application.resourceTrackingMethod=annotation \
  -f bootstrap-argocd-values.yaml \
  --wait

# we add the repo inside the application-controller because it could be that clusters do not have any ingress controller installed yet at this moment
echo "add kubriX repo in argocd pod"
kubectl exec "$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}')" -n argocd -- argocd repo add ${KUBRIX_REPO} --username ${KUBRIX_REPO_USERNAME} --password ${KUBRIX_REPO_PASSWORD} --core

# add secrets
  echo "Generating default secrets..."
  ./.secrets/createsecret.sh
# create the secrets.yaml and pushsecrets.yaml but only apply them when KUBRIX_GENERATE_SECRETS is true
# reason: we always want to delete the pushsecrets at the end so you can manage those secrets via vault
#         so we let createsecret.sh create the secrets.yaml and pushsecrets.yaml, not apply them when KUBRIX_GENERATE_SECRETS is not true, but always delete them at the end of the script
if [ ${KUBRIX_GENERATE_SECRETS} = "true" ] ; then
  kubectl apply -f ./.secrets/secrettemp/secrets.yaml
fi

KUBRIX_REPO_BRANCH_SED=$( printf '%s' "${KUBRIX_REPO_BRANCH}" | sed -e 's/[\/&]/\\&/g' );
KUBRIX_REPO_SED=$( printf '%s' "${KUBRIX_REPO}" | sed -e 's/[\/&]/\\&/g' );

# bootstrap-app
cat bootstrap-app-${KUBRIX_TARGET_TYPE}.yaml | sed "s/targetRevision:.*/targetRevision: ${KUBRIX_REPO_BRANCH_SED}/g" | sed "s/repoURL:.*/repoURL: ${KUBRIX_REPO_SED}/g" | kubectl apply -n argocd -f -

# create app list
target_chart_value_file="platform-apps/target-chart/values-${KUBRIX_TARGET_TYPE}.yaml"

base_apps=$(egrep -Ev "team-onboarding" "${target_chart_value_file}" | awk '/^  - name:/ { printf "%s", "sx-"$3" " }')
# list apps which need some sort of special treatment in bootstrap
base_apps_without_individual=$(egrep -Ev "team-onboarding" "${target_chart_value_file}" | awk '/^  - name:/ { printf "%s", "sx-"$3" " }')

if [[ -n "${KUBRIX_APP_EXCLUDE:-}" ]]; then
  argocd_apps=$(exclude_apps "$base_apps" "$KUBRIX_APP_EXCLUDE")
  argocd_apps_without_individual=$(exclude_apps "$base_apps_without_individual" "$KUBRIX_APP_EXCLUDE")
else
  argocd_apps="$base_apps"
  argocd_apps_without_individual="$base_apps_without_individual"
fi

# max wait for 20 minutes until all apps except backstage and kargo are synced and healthy
wait_until_apps_synced_healthy "${argocd_apps_without_individual}" "Synced" "Healthy" ${KUBRIX_BOOTSTRAP_MAX_WAIT_TIME}

# if vault is part of this stack, do some special configuration
if [[ $( echo $argocd_apps | grep sx-vault ) ]] ; then

  export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
  export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)

  # due to issue #422 this step is needed for all clusters
  GROUP_ALIAS_LIST=$(curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request LIST https://${VAULT_HOSTNAME}/v1/identity/group-alias/id)
  if [ -z "$(echo "$GROUP_ALIAS_LIST" | jq -r '.data.keys | length')" ] || [ "$(echo "$GROUP_ALIAS_LIST" | jq -r '.data.keys | length')" -eq 0 ]; then
      echo "No group aliases found. Setting up group aliases..."
      # Get the list of identity groups
      GROUP_LIST=$(curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request LIST https://${VAULT_HOSTNAME}/v1/identity/group/name)
      # Get OIDC accessor
      ACC=$(curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request GET https://${VAULT_HOSTNAME}/v1/sys/auth | jq -r '.["oidc/"].accessor')
      echo "OIDC Accessor: $ACC"
      # Iterate over groups and create group aliases
      echo "$GROUP_LIST" | jq -r '.data.keys[]' | while read -r GROUP_NAME; do
          echo "Processing group: $GROUP_NAME"
          # Get Group ID
          GROUP_ID=$(curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request GET https://${VAULT_HOSTNAME}/v1/identity/group/name/$GROUP_NAME | jq -r '.data.id')
          if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "null" ]; then
              # Create Group Alias
              RESPONSE=$(curl -k --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"name": "'$GROUP_NAME'", "mount_accessor": "'$ACC'", "canonical_id": "'$GROUP_ID'"}' https://${VAULT_HOSTNAME}/v1/identity/group-alias)
              echo "Group alias created for $GROUP_NAME: $RESPONSE"
          fi
      done
  fi
fi
  
# when we are in a github codespace, we need to add special backstage env variables
if [[ "${CODESPACES:-}" == "true" ]]; then
  if [[ $( echo $argocd_apps | grep sx-backstage ) ]] ; then

    # delete secret if it already exists
    if kubectl get secret -n backstage codespaces-secret > /dev/null 2>&1 ; then
      kubectl delete secret -n backstage codespaces-secret
    fi
    
    BACKSTAGE_CODESPACE_URL="https://${CODESPACE_NAME}-6691.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

    kubectl create secret generic -n backstage codespaces-secret \
    --from-literal=APP_CONFIG_app_baseUrl=${BACKSTAGE_CODESPACE_URL} \
    --from-literal=APP_CONFIG_backend_baseUrl=${BACKSTAGE_CODESPACE_URL} \
    --from-literal=APP_CONFIG_backend_cors_origin=${BACKSTAGE_CODESPACE_URL} \
    --from-literal=APP_CONFIG_auth_provider_github_development_callbackUrl=${BACKSTAGE_CODESPACE_URL}/api/auth/github/handler/frame \
    --dry-run=client -o yaml | kubectl apply -f -

    kubectl rollout restart deployment sx-backstage -n backstage

    # finally wait for backstage to be synced and healthy
    wait_until_apps_synced_healthy "sx-backstage" "Synced" "Healthy" 600
  fi
fi

# remove pushsecrets
kubectl delete -f ./.secrets/secrettemp/pushsecrets.yaml

# print the rootCA so users can import it in their browsers

if [[ "${KUBRIX_CLUSTER_TYPE}" == "kind" ]] ; then
  echo "Installation finished! On KinD clusters we create self-signed certificates for our platform services. You probably need to import this CA cert in your browser to accept the certificates:"
  kubectl get secret mkcert-ca-key-pair -n cert-manager -o jsonpath="{['data']['tls\.crt']}" | base64 --decode
fi

