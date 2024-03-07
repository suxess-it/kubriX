# cnp local demo environment

## how to set it up

### 1. create k3d cluster

curl -L https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/install-k3d-cluster.sh | sh

for additional information read https://argo-cd.readthedocs.io/en/stable/getting_started/

the platform stack will be installed automatically

backstage
argocd (managed by argocd)
argo-rollouts
kargo
cert-manager
crossplane
kyverno
prometheus
grafana

### 2. log in to argocd

in your favorite browser:  http://argocd-127-0-0-1.nip.io:8666/

Username: `admin`
Passwort: `kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

vlt sowas wie https://github.com/jkleinlercher/argocd-suxess-example?tab=readme-ov-file#argocd-aufrufen


### delete k3d cluster

```
k3d cluster stop cnp-local-demo
k3d cluster delete cnp-local-demo
```