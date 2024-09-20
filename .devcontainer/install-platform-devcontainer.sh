#!/bin/bash
set -e  # Exit on non-zero exit code from commands

echo "$(date): Running post-start.sh" >> ~/.status.log

# fix for https://github.com/kubernetes-sigs/kind/issues/2488
# but using the microsoft devcontainer docker-in-docker image should also work,
# but I didn't find it
if [[ $( docker network ls | grep kind ) ]] ; then
  echo "kind network already exists"
else
  docker network create -d=bridge --subnet=172.19.0.0/24 kind
fi

# this runs in background each time the container starts

export GITHUB_CLIENTSECRET=dummy
export GITHUB_CLIENTID=dummy
export GITHUB_TOKEN=dummy
export GITHUB_APPSET_TOKEN=dummy
export CURRENT_BRANCH=$( git rev-parse --abbrev-ref HEAD )
#export CREATE_K3D_CLUSTER=true

# install mkcert
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

# create kind cluster by ourselves
if [[ $( kind get clusters | grep devcontainer-cluster ) ]] ; then
  echo "kind cluster 'devcontainer-cluster' already exists"
  echo "wait 10 seconds for starting up ..."
  sleep 10
  echo "wait time over .."
else
  kind create cluster --name devcontainer-cluster --config .devcontainer/kind-config.yaml
fi

# here we can add some NodePort objects if we want to open ports before the apps are installed
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f .devcontainer/argocd-nodeport.yaml

# Ensure kubeconfig is set up. 
# k3d kubeconfig merge dev --kubeconfig-merge-default

./install-platform.sh

if [[ ${TARGET_TYPE} == "KIND-DELIVERY" ]] ; then
  # forward argocd and kargo so it gets also exposed in github codespace
  # nohup kubectl -n argocd port-forward svc/sx-argocd-server 6688:80 &
  # nohup kubectl -n kargo port-forward svc/kargo-api 6689:80 &

  argocd_password=$( kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' | base64 -d )

  echo "kubrix delivery is set up sucessfully."
  echo "ArgoCD url: https://${CODESPACE_NAME}-6688.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  echo "ArgoCD user: admin"
  echo "ArgoCD password: ${argocd_password}"
  echo ""
  echo "Kargo url: https://${CODESPACE_NAME}-6689.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  echo "Kargo password: admin"
fi

echo "$(date): Finished post-start.sh" >> ~/.status.log
