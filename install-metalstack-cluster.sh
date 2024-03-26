#!/bin/sh

set -x

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

# install a bootstrap app which then installs the whole stack automagically
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/bootstrap-app-metalstack.yaml -n argocd
