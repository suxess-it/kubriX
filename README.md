# cnp local demo environment

## how to set it up

### prereqs

k3d installed
kubectl installed

### 1. create k3d cluster

```
curl -L https://raw.githubusercontent.com/jkleinlercher/cnp-local-demo/main/install-k3d-cluster.sh | sh
```

With this command a new k3d cluster gets created.
A "bootstrap argocd" get's installed via helm.
A "boostrap-app" gets installed which references all other apps in the plattform-stack (app-of-apps pattern)
ArgoCD itself is also then managed by an argocd app.

The platform stack will be installed automatically:

backstage
argocd (managed by argocd)
argo-rollouts
kargo
cert-manager
crossplane
kyverno
prometheus
grafana

### 2. wait until everything is app and running

wait until all pods are started:

```
watch kubectl get pods -A
```

wait until all apps are synced and healthy

```
kubectl get applications -n argocd
```

Known Problem: in the first couple of minutes the sx-bootstrap-app gets a compare error:

```
      message: 'Failed to load target state: failed to generate manifest for source
        1 of 1: rpc error: code = Unavailable desc = connection error: desc = "transport:
        Error while dialing: dial tcp 10.43.244.1:8081: connect: connection refused"'
```

Verbindung zum argocd-repo-server Service.




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