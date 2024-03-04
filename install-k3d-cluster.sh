#!/bin/sh

set -x

k3d cluster create cnp-local-demo \
  -p "8666:80@loadbalancer" \
  --agents 2 \
  --wait

# boostrap with argocd and the bootstrap-app
kubectl create namespace argocd

kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd 
kubectl apply -f https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/boostrap-app.yaml -n argocd
kubectl rollout restart deployment argocd-server -n argocd