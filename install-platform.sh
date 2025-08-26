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
      echo "set ${variable} to sane default '${!variable}'"
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
  check_variable KUBRIX_REPO_BRANCH "true"
  check_variable KUBRIX_REPO_USERNAME "true"
  check_variable KUBRIX_REPO_PASSWORD "false"
  check_variable KUBRIX_BACKSTAGE_GITHUB_TOKEN "false"
  check_variable KUBRIX_TARGET_TYPE "true"
  check_variable KUBRIX_CLUSTER_TYPE "true" "k8s"
  check_variable KUBRIX_BOOTSTRAP_MAX_WAIT_TIME "true" "1800"
  check_variable KUBRIX_INSTALLER "true" "false"

  # check tools
  check_tool yq "yq --version"
  check_tool jq "jq --version"
  check_tool kubectl "kubectl version --client=true"
  check_tool helm "helm version"
  check_tool curl "curl -V | head -1"

  if [[ "${KUBRIX_TARGET_TYPE}" =~ ^KIND.* || "${KUBRIX_CLUSTER_TYPE}" == "KIND" ]] ; then
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
          if [ ! -f ./.secrets/secrettemp/secrets-applied ]; then
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


ARCH=$(uname -m)
OS=$(uname -s)

check_prereqs

# Portable date(1) detection + helpers
if command -v gdate >/dev/null 2>&1; then
  DATE_BIN="$(command -v gdate)"
else
  DATE_BIN="$(command -v date)"
fi
DATE_IMPL="$(detect_date_impl)"

# checkout upstream repo when running inside kubrix-installer job
if [ ${KUBRIX_INSTALLER} = "true" ] ; then
  printf 'checkout kubriX to %s ...\n' "$(pwd)/kubriX"
  mkdir kubriX
  git clone "${KUBRIX_REPO}" kubriX
  cd kubriX
  git checkout "${KUBRIX_REPO_BRANCH}"
fi

if [[ "${KUBRIX_TARGET_TYPE}" =~ ^KIND.* || "${KUBRIX_CLUSTER_TYPE}" == "KIND" ]] ; then
  
  # resolv domainname to ingress adress to solve localhost result 
  kubectl get configmap coredns -n kube-system -o yaml |  awk '
/ready/ {
    print;
    print "        rewrite name keycloak.127-0-0-1.nip.io ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name grafana.127-0-0-1.nip.io ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name argocd.127-0-0-1.nip.io ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    print "        rewrite name vault.127-0-0-1.nip.io ingress-nginx-controller.ingress-nginx.svc.cluster.local";
    next
}
{ print }
' > coredns-configmap.yaml
  kubectl apply -f coredns-configmap.yaml
  kubectl rollout restart deployment coredns -n kube-system
  rm coredns-configmap.yaml

  # and install nginx ingress-controller
  echo "installing nginx ingress controller in KinD"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

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
  kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[
  {
      "op": "add",
      "path": "/spec/template/spec/containers/0/args/-",
      "value": "--enable-ssl-passthrough"
  },
  ]'

  # curl should trust all websites with the mkcert cert
  export CURL_CA_BUNDLE="$(mkcert -CAROOT)"/rootCA-key.pem

  # wait until ingress-nginx-controller is ready
  echo "wait until ingress-nginx-controller is running ..."
  sleep 10
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

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
  --version 7.8.24 \
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
kubectl apply -f ./.secrets/secrettemp/secrets.yaml

KUBRIX_REPO_BRANCH_SED=$( printf '%s' "${KUBRIX_REPO_BRANCH}" | sed -e 's/[\/&]/\\&/g' );
KUBRIX_REPO_SED=$( printf '%s' "${KUBRIX_REPO}" | sed -e 's/[\/&]/\\&/g' );

# bootstrap-app
cat bootstrap-app-$(echo ${KUBRIX_TARGET_TYPE} | awk '{print tolower($0)}').yaml | sed "s/targetRevision:.*/targetRevision: ${KUBRIX_REPO_BRANCH_SED}/g" | sed "s/repoURL:.*/repoURL: ${KUBRIX_REPO_SED}/g" | kubectl apply -n argocd -f -

# create app list
target_chart_value_file="platform-apps/target-chart/values-$(echo ${KUBRIX_TARGET_TYPE} | awk '{print tolower($0)}').yaml"

argocd_apps=$(cat $target_chart_value_file | egrep -Ev "team-onboarding" | awk '/^  - name:/ { printf "%s", "sx-"$3" "}' )
# list apps which need some sort of special treatment in bootstrap
argocd_apps_without_individual=$(cat $target_chart_value_file | egrep -Ev "team-onboarding" | awk '/^  - name:/ { printf "%s", "sx-"$3" "}' )

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

# remove pushsecrets and status files
kubectl delete -f ./.secrets/secrettemp/pushsecrets.yaml
