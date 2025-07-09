#!/bin/bash

# variables which must be defined by user
while read var; do
  [ -z "${!var}" ] && { echo "$var is empty or not set. Exiting.."; exit 1; }
done << EOF
KUBRIX_CUSTOMER_REPO
KUBRIX_CUSTOMER_REPO_TOKEN
EOF

# variables with possible sane defaults
KUBRIX_UPSTREAM_REPO=${KUBRIX_UPSTREAM_REPO:-"https://github.com/suxess-it/kubriX"}
KUBRIX_UPSTREAM_BRANCH=${KUBRIX_UPSTREAM_BRANCH:-"main"}
KUBRIX_CUSTOMER_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE:-"DEMO-STACK"}
KUBRIX_CUSTOMER_DOMAIN=${KUBRIX_CUSTOMER_DOMAIN:-"demo-$(echo ${KUBRIX_CUSTOMER_REPO} | sha256sum | head -c 10).kubrix.cloud"}
KUBRIX_CUSTOMER_DNS_PROVIDER=${KUBRIX_CUSTOMER_DNS_PROVIDER:-"ionos"}

# get protocol
KUBRIX_CUSTOMER_REPO_PROTO=$(echo ${KUBRIX_CUSTOMER_REPO} | grep :// | sed "s,^\(.*://\).*,\1,")
# remove the protocol from url
KUBRIX_CUSTOMER_REPO_URL=$(echo ${KUBRIX_CUSTOMER_REPO} | sed "s,^${KUBRIX_CUSTOMER_REPO_PROTO},,")
# get git server organization (for backstage scaffolder templates)
KUBRIX_CUSTOMER_REPO_ORG=$(echo $KUBRIX_CUSTOMER_REPO_URL | awk -F/ '{print $2}')
# get name of the repo
KUBRIX_CUSTOMER_REPO_NAME=$(echo $KUBRIX_CUSTOMER_REPO_URL | awk -F/ '{print $3}')

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
cd $HOME
if [ -d "bootstrap-kubriX" ]; then
  echo "boostrap-kubriX already exists. We will delete it."
  rm -rf bootstrap-kubriX
fi
mkdir -p bootstrap-kubriX/kubriX-repo
cd bootstrap-kubriX/kubriX-repo
echo "checkout kubriX to $(pwd) ..."
git clone ${KUBRIX_UPSTREAM_REPO} .
git checkout ${KUBRIX_UPSTREAM_BRANCH}

# write new customer values in customer config
cat << EOF > bootstrap/customer-config.yaml
clusterType: $( echo ${KUBRIX_CLUSTER_TYPE} | awk '{print tolower($0)}' )
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
curl --progress-bar -o gomplate -SL https://github.com/hairyhenderson/gomplate/releases/download/v4.3.2/gomplate_linux-amd64
chmod 755 gomplate

echo "rendering values templates ..."
valuesFile=$( echo ${KUBRIX_CUSTOMER_TARGET_TYPE} | awk '{print tolower($0)}' )
gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir platform-apps --include *${valuesFile}.yaml.tmpl --output-map='platform-apps/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
rm gomplate

echo "Push kubriX gitops files to ${KUBRIX_CUSTOMER_REPO}"
git remote add customer ${KUBRIX_CUSTOMER_REPO_PROTO}${KUBRIX_CUSTOMER_REPO_TOKEN}@${KUBRIX_CUSTOMER_REPO_URL}
git add -A
git commit -a -m "add customer specific modifications during bootstrap"
git push --set-upstream customer ${KUBRIX_UPSTREAM_BRANCH}:main

echo "Now run install-platform.sh from your new kubriX repo ${KUBRIX_CUSTOMER_REPO}"

export KUBRIX_BACKSTAGE_GITHUB_CLIENTID=dummy
export KUBRIX_BACKSTAGE_GITHUB_CLIENTSECRET=dummy
export KUBRIX_BACKSTAGE_GITHUB_TOKEN=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_REPO=${KUBRIX_CUSTOMER_REPO}
export KUBRIX_REPO_BRANCH=main
export KUBRIX_REPO_USERNAME=dummy
export KUBRIX_REPO_PASSWORD=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE}
export KUBRIX_CREATE_K3D_CLUSTER=false
export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=2000

# install-platform from new repository
./install-platform.sh

rc=$?
if [ $rc -ne 0 ]; then
  echo "install-platform.sh was not sucessful. To rerun the installation with the already existing customer repo ${KUBRIX_CUSTOMER_REPO} just export these variables:\
  
  
  export KUBRIX_BACKSTAGE_GITHUB_CLIENTID=dummy
  export KUBRIX_BACKSTAGE_GITHUB_CLIENTSECRET=dummy
  export KUBRIX_BACKSTAGE_GITHUB_TOKEN=${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_REPO=${KUBRIX_CUSTOMER_REPO}
  export KUBRIX_REPO_BRANCH=main
  export KUBRIX_REPO_USERNAME=dummy
  export KUBRIX_REPO_PASSWORD=${KUBRIX_CUSTOMER_REPO_TOKEN}
  export KUBRIX_TARGET_TYPE=${KUBRIX_CUSTOMER_TARGET_TYPE}
  export KUBRIX_CREATE_K3D_CLUSTER=false
  export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=2000
  
  and then 
  
  cd "$HOME/bootstrap-kubriX/kubriX-repo"
  ./install-platform.sh
  "
else
  echo "kubriX bootstrapped sucessfully!"
fi

