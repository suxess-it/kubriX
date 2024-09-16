#!/bin/bash
set -e  # Exit on non-zero exit code from commands

set -x

echo "$(date): Running post-start.sh" >> ~/.status.log

# this runs in background each time the container starts

export GITHUB_CLIENTSECRET=dummy
export GITHUB_CLIENTID=dummy
export GITHUB_TOKEN=dummy
export GITHUB_APPSET_TOKEN=dummy
export TARGET_TYPE=KIND-DELIVERY
export CURRENT_BRANCH=feat/devcontainer
export CREATE_K3D_CLUSTER=true

# install mkcert
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

# kind create cluster --name devcontainer-cluster --config=.github/kind-config.yaml

k3d cluster list

# Ensure kubeconfig is set up. 
# k3d kubeconfig merge dev --kubeconfig-merge-default

./install-platform.sh

# forward argocd and kargo so it gets also exposed in github codespace
kubectl create ns blabla-test
nohup kubectl -n argocd port-forward svc/sx-argocd-server 6688:80 &
nohup kubectl -n kargo port-forward svc/kargo-api 6689:80 &

argocd_password=$( kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' | base64 -d )

echo "kubrix delivery is set up sucessfully."
echo "ArgoCD user: admin"
echo "ArgoCD password: ${argocd_password}"
echo ""
echo "Kargo password: admin"

echo "$(date): Finished post-start.sh" >> ~/.status.log
