#!/bin/bash

full_path=$(realpath $0)
dir_path=$(dirname $full_path)
KUBRIX_UPSTREAM_REPO="https://github.com/suxess-it/kubriX"
KUBRIX_UPSTREAM_BRANCH="feat/template-values-files"

# just a mvp to get the params via shell input (in the future some better methods would be needed)
KUBRIX_CUSTOMER_REPO=$1
KUBRIX_CUSTOMER_REPO_TOKEN=$2
KUBRIX_CUSTOMER_DOMAIN=$3

# git clone if bootstrap.sh was executed via curl|bash
mkdir -p bootstrap-kubriX/kubriX-repo
cd bootstrap-kubriX/kubriX-repo
git clone ${KUBRIX_UPSTREAM_REPO} .
git checkout ${KUBRIX_UPSTREAM_BRANCH}

pwd

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
gomplate --context kubriX=$bootstrap/customer-config.yaml --input-dir platform-apps/charts --include *.yaml.tmpl --output-map='platform-apps/charts/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
rm gomplate

cat << EOF

to push this repo to the new emtpy customer repo do the following

# 1. create new empty customer repo

# 2. create an access token for this repo with write access

# 3. save the repo url and token in this variables like this:

KUBRIX_CUSTOMER_REPO="github.com/kubriX-demo/kubriX-demo-customerXY"
KUBRIX_CUSTOMER_REPO_TOKEN="blabla"

# 4. execute the following git commands:

git remote add customer https://\${KUBRIX_CUSTOMER_REPO_TOKEN}@\${KUBRIX_CUSTOMER_REPO}.git
git add -A
git commit -a -m "add rendered values files"
git push --set-upstream customer ${KUBRIX_UPSTREAM_BRANCH}:main
EOF

git remote add customer https://\${KUBRIX_CUSTOMER_REPO_TOKEN}@\${KUBRIX_CUSTOMER_REPO}.git
git add -A
git commit -a -m "add rendered values files"
git push --set-upstream customer ${KUBRIX_UPSTREAM_BRANCH}:main

echo "Now run install-platform.sh from your new kubriX repo"
