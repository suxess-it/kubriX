#!/bin/bash

KUBRIX_UPSTREAM_REPO="https://github.com/suxess-it/kubriX"
KUBRIX_UPSTREAM_BRANCH="feat/template-values-files"

# just a mvp to get the params via shell input (in the future some better methods would be needed)
KUBRIX_CUSTOMER_REPO=$1
KUBRIX_CUSTOMER_REPO_TOKEN=$2
KUBRIX_CUSTOMER_DOMAIN=$3

# git clone if bootstrap.sh was executed via curl|bash
mkdir -p bootstrap-kubriX/kubriX-repo
cd bootstrap-kubriX/kubriX-repo
echo "checkout kubriX to $(pwd) ..."
git clone ${KUBRIX_UPSTREAM_REPO} .
git checkout ${KUBRIX_UPSTREAM_BRANCH}

# write new customer values in customer config
cat << EOF > bootstrap/customer-config.yaml
domain: ${KUBRIX_CUSTOMER_DOMAIN}
EOF

# before executing this script, the bootstrap/customer-config.yaml file needs to get changed to the customer instance
echo "the current customer-config is like this:"
echo "----"
cat bootstrap/customer-config.yaml
echo "----"

echo "downloading gomplate ..."
curl -o gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v4.3.2/gomplate_linux-amd64
chmod 755 gomplate

echo "rendering values templates ..."
gomplate --context kubriX=bootstrap/customer-config.yaml --input-dir platform-apps/charts --include *.yaml.tmpl --output-map='platform-apps/charts/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
rm gomplate

git remote add customer https://${KUBRIX_CUSTOMER_REPO_TOKEN}@${KUBRIX_CUSTOMER_REPO}.git
git add -A
git commit -a -m "add rendered values files"
git push --set-upstream customer ${KUBRIX_UPSTREAM_BRANCH}:main

echo "Now run install-platform.sh from your new kubriX repo"

export KUBRIX_BACKSTAGE_GITHUB_CLIENTID=dummy
export KUBRIX_BACKSTAGE_GITHUB_CLIENTSECRET=dummy
export KUBRIX_BACKSTAGE_GITHUB_TOKEN=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_REPO=https://${KUBRIX_CUSTOMER_REPO}
export KUBRIX_REPO_BRANCH=main
export KUBRIX_REPO_USERNAME=dummy
export KUBRIX_REPO_PASSWORD=${KUBRIX_CUSTOMER_REPO_TOKEN}
export KUBRIX_TARGET_TYPE=DEMO-METALSTACK
export KUBRIX_CREATE_K3D_CLUSTER=false
export KUBRIX_BOOTSTRAP_MAX_WAIT_TIME=2000

# install-platform from new repository
./install-platform.sh