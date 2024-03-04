# cnp local demo environment

## how to set it up

### 1. create k3d cluster

curl -L https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/install-k3d-cluster.sh | sh

for additional information read https://argo-cd.readthedocs.io/en/stable/getting_started/

the platform stack will be installed automatically

backstage
argocd (managed by argocd)
crossplane
kyverno
prometheus
grafana

### 2. log in to argocd

vlt sowas wie https://github.com/jkleinlercher/argocd-suxess-example?tab=readme-ov-file#argocd-aufrufen

#TODO: maybe we will add some extensions also like in
https://raw.githubusercontent.com/akuity/kargo/main/hack/quickstart/k3d.sh

(especially argo-rollouts extension) --> or lets do this in the argocd app