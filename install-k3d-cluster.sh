#!/bin/sh

set -x

# do we need to set this always? I had DNS issues on the train
export K3D_FIX_DNS=1

k3d cluster create cnp-local-demo \
  -p "8666:80@loadbalancer" \
  -p "8667:443@loadbalancer" \
  --agents 2 \
  --wait

# boostrap with argocd and the bootstrap-app
kubectl create namespace argocd

# create argocd with helm chart not with install.yaml
# because afterwards argocd is also managed by itself with the helm-chart

helm install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version 6.4.0 \
  --namespace argocd \
  --create-namespace \
  --set additionalLabels."app\.kubernetes\.io/instance"=argocd \
  --wait

kubectl apply -f https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/bootstrap-app.yaml -n argocd

mkcert -cert-file argocd-cert.pem -key-file argocd-key.pem nip.io argocd-127-0-0-1.nip.io
kubectl create secret tls argocd-server-tls -n argocd --cert=argocd-cert.pem --key=argocd-key.pem


