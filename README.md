# cnp local demo environment

## how to set it up

### 1. create k3d cluster

<tbd>how to create a k3d cluster</tbd>

### 2. install argocd imperativ for bootstrapping

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

configure argocd-server to run insecure (just because of k3d) and configure argocd ingress
#TODO: this should go in my argocd app!

```
kubectl apply -f https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/argocd-cmd-params-cm.yaml -n argocd

kubectl rollout restart deployment argocd-server -n argocd

kubectl apply -f https://raw.githubusercontent.com/jkleinlercher/argocd-suxess-example/main/ingress-argocd.yaml -n argocd
```

for additional information read https://argo-cd.readthedocs.io/en/stable/getting_started/

### 2b log in to argocd

vlt sowas wie https://github.com/jkleinlercher/argocd-suxess-example?tab=readme-ov-file#argocd-aufrufen


### 3. apply bootstrap app

<tbd>kubectl apply -f bootstrap-app.yaml -n argocd</tbd>

4. the platform stack will be installed automatically

backstage
argocd (managed by argocd)
crossplane
kyverno
prometheus
grafana
