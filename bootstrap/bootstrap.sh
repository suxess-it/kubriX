#!/bin/bash

full_path=$(realpath $0)
dir_path=$(dirname $full_path)

# before executing this script, the bootstrap/customer-config.yaml file needs to get changed to the customer instance
echo "the current customer-config is like this:"
echo "----"
cat ${dir_path}/customer-config.yaml
echo "----"

echo "downloading gomplate ..."
curl -o gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v4.3.2/gomplate_linux-amd64
chmod 755 gomplate

echo "rendering values templates ..."
gomplate --context kubriX=${dir_path}/customer-config.yaml --input-dir ${dir_path}/../platform-apps/charts --include *.yaml.tmpl --output-map='${dir_path}/../platform-apps/charts/{{ .in | strings.ReplaceAll ".yaml.tmpl" ".yaml" }}'
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
git push --set-upstream customer main
EOF