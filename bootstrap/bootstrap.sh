#!/usr/bin/env bash

set -Eeuo pipefail

# Simple error trap
fail() {

  echo "install-platform.sh was not sucessful. To rerun the installation with the already existing customer repo ${KUBRIX_CUSTOMER_REPO} just export these variables:\
  

  export KUBRIX_BACKSTAGE_GITHUB_TOKEN=\${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_REPO=${KUBRIX_CUSTOMER_REPO}
  export KUBRIX_REPO_BRANCH=main
  export KUBRIX_REPO_USERNAME=dummy
  export KUBRIX_REPO_PASSWORD=\${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE}
  export KUBRIX_CLUSTER_TYPE=${KUBRIX_CLUSTER_TYPE}
  export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=${KUBRIX_BOOTSTRAP_MAX_WAIT_TIME}
  
  and then 
  
  cd "$HOME/bootstrap-kubriX/kubriX-repo"
  ./install-platform.sh
  "

  printf '%s\n' "$1" >&2; exit "${2:-1}";
}

trap 'fail "Error on line $LINENO"' ERR

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

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

OS="$(detect_os)"
ARCH="$(detect_arch)"

# variables which must be defined by user
while read -r var; do
  if [ -z "${!var-}" ]; then
    printf '%s\n' "$var is empty or not set. Exiting.."
    exit 1
  fi
done <<'EOF'
KUBRIX_CUSTOMER_REPO
KUBRIX_CUSTOMER_REPO_TOKEN
EOF

# variables with possible sane defaults
KUBRIX_UPSTREAM_REPO=${KUBRIX_UPSTREAM_REPO:-"https://github.com/suxess-it/kubriX"}
KUBRIX_UPSTREAM_BRANCH=${KUBRIX_UPSTREAM_BRANCH:-"main"}
KUBRIX_CUSTOMER_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE:-"DEMO-STACK"}
KUBRIX_CUSTOMER_DOMAIN=${KUBRIX_CUSTOMER_DOMAIN:-"demo-$(printf '%s' "${KUBRIX_CUSTOMER_REPO}" | sha256_portable | head -c 10).kubrix.cloud"}
KUBRIX_CUSTOMER_DNS_PROVIDER=${KUBRIX_CUSTOMER_DNS_PROVIDER:-"ionos"}
KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=${KUBRIX_BOOTSTRAP_MAX_WAIT_TIME:-"3600"}
KUBRIX_CLUSTER_TYPE=${KUBRIX_CLUSTER_TYPE:-"k8s"}

# get protocol
KUBRIX_CUSTOMER_REPO_PROTO=$(echo ${KUBRIX_CUSTOMER_REPO} | grep :// | sed "s,^\(.*://\).*,\1,")
# remove the protocol from url
KUBRIX_CUSTOMER_REPO_URL=$(echo ${KUBRIX_CUSTOMER_REPO} | sed "s,^${KUBRIX_CUSTOMER_REPO_PROTO},,")
# get git server organization (for backstage scaffolder templates)
KUBRIX_CUSTOMER_REPO_ORG=$(echo $KUBRIX_CUSTOMER_REPO_URL | awk -F/ '{print $2}')
# get name of the repo
KUBRIX_CUSTOMER_REPO_NAME=$(echo $KUBRIX_CUSTOMER_REPO_URL | awk -F/ '{print $3}')
# remove .git suffix if it exists
KUBRIX_CUSTOMER_REPO_NAME=${KUBRIX_CUSTOMER_REPO_NAME%".git"}

echo ""
echo "-------------------------------------------------------------"
echo "kubriX will get bootstrapped with the following parameters:"
echo "-------------------------------------------------------------"
echo "KUBRIX_UPSTREAM_REPO: ${KUBRIX_UPSTREAM_REPO}"
echo "KUBRIX_UPSTREAM_BRANCH: ${KUBRIX_UPSTREAM_BRANCH}"
echo "KUBRIX_CUSTOMER_REPO: ${KUBRIX_CUSTOMER_REPO}"
echo "KUBRIX_CUSTOMER_REPO_ORG: ${KUBRIX_CUSTOMER_REPO_ORG}"
echo "KUBRIX_CUSTOMER_REPO_NAME: ${KUBRIX_CUSTOMER_REPO_NAME}"
echo "KUBRIX_CUSTOMER_TARGET_TYPE: ${KUBRIX_CUSTOMER_TARGET_TYPE}"
echo "KUBRIX_CUSTOMER_DOMAIN: ${KUBRIX_CUSTOMER_DOMAIN}"
echo "KUBRIX_CUSTOMER_DNS_PROVIDER: ${KUBRIX_CUSTOMER_DNS_PROVIDER}"
echo "-------------------------------------------------------------"
echo ""

# clone kubriX upstream repo to bootstrap-kubriX/kubriX-repo
cd "$HOME"
if [ -d "bootstrap-kubriX" ]; then
  printf '%s\n' "boostrap-kubriX already exists. We will delete it."
  rm -rf bootstrap-kubriX
fi
mkdir -p bootstrap-kubriX/kubriX-repo
cd bootstrap-kubriX/kubriX-repo

printf 'checkout kubriX to %s ...\n' "$(pwd)"
git clone "${KUBRIX_UPSTREAM_REPO}" .
git checkout "${KUBRIX_UPSTREAM_BRANCH}"

# Create an orphan branch that has NO parents
git checkout --orphan publish

# now add one commit before we do the customer specific changes
git reset --mixed
git add -A
git commit -m "Initial publish: squashed snapshot of kubriX"

# write new customer values in customer config
cat << EOF > bootstrap/customer-config.yaml
clusterType: $( printf '%s' "${KUBRIX_CLUSTER_TYPE}" | awk '{print tolower($0)}' )
valuesFile: $( printf '%s' "${KUBRIX_CUSTOMER_TARGET_TYPE}" | awk '{print tolower($0)}' )
dnsProvider: ${KUBRIX_CUSTOMER_DNS_PROVIDER}
domain: ${KUBRIX_CUSTOMER_DOMAIN}
gitRepo: ${KUBRIX_CUSTOMER_REPO}
gitRepoOrg: ${KUBRIX_CUSTOMER_REPO_ORG}
gitRepoName: ${KUBRIX_CUSTOMER_REPO_NAME}
EOF

echo "the current customer-config is like this:"
echo "----"
cat bootstrap/customer-config.yaml
echo "----"

echo "downloading gomplate ..."
curl --progress-bar -o gomplate -SL https://github.com/hairyhenderson/gomplate/releases/download/v4.3.2/gomplate_${OS}-${ARCH}
chmod 755 gomplate

echo "rendering values templates ..."
valuesFile=$( echo ${KUBRIX_CUSTOMER_TARGET_TYPE} | awk '{print tolower($0)}' )
./gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir platform-apps --include *${valuesFile}.yaml.tmpl --output-map='platform-apps/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
./gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir backstage-resources --include *.yaml.tmpl --output-map='backstage-resources/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
rm gomplate

echo "Push kubriX gitops files to ${KUBRIX_CUSTOMER_REPO}"
git remote add customer ${KUBRIX_CUSTOMER_REPO_PROTO}${KUBRIX_CUSTOMER_REPO_TOKEN}@${KUBRIX_CUSTOMER_REPO_URL}
git add -A
git commit -a -m "add customer specific modifications during bootstrap"
git push --set-upstream customer publish:main

echo "Now run install-platform.sh from your new kubriX repo ${KUBRIX_CUSTOMER_REPO}"

export KUBRIX_BACKSTAGE_GITHUB_TOKEN=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_REPO=${KUBRIX_CUSTOMER_REPO}
export KUBRIX_REPO_BRANCH=main
export KUBRIX_REPO_USERNAME=dummy
export KUBRIX_REPO_PASSWORD=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE}
export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=${KUBRIX_BOOTSTRAP_MAX_WAIT_TIME}

# install-platform from new repository
./install-platform.sh

rc=$?
if [ $rc -ne 0 ]; then
  echo "install-platform.sh was not sucessful. To rerun the installation with the already existing customer repo ${KUBRIX_CUSTOMER_REPO} just export these variables:\
  
  
  export KUBRIX_BACKSTAGE_GITHUB_TOKEN=\${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_REPO=${KUBRIX_CUSTOMER_REPO}
  export KUBRIX_REPO_BRANCH=main
  export KUBRIX_REPO_USERNAME=dummy
  export KUBRIX_REPO_PASSWORD=\${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE}
  export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=${KUBRIX_BOOTSTRAP_MAX_WAIT_TIME}
  
  and then 
  
  cd "$HOME/bootstrap-kubriX/kubriX-repo"
  ./install-platform.sh
  "
else
  echo "kubriX bootstrapped sucessfully!"
fi

