# cnp local demo environment

## how to set it up

### prereqs

k3d installed
kubectl installed

mkcert

```
curl -L -O https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
mv mkcert-v1.4.4-linux-amd64 ~/bin/mkcert
chmod u+x ~/bin/mkcert
```



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

### 3. log in to argocd

in your favorite browser:  https://argocd-127-0-0-1.nip.io:8667/

if argocd says "server.secretkey" is missing, try

```
kubectl rollout restart deploy/argocd-server -n argocd
```

Username: `admin`
Password: `kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

### 4. log in to kargo

in your favorite browser:  http://kargo-127-0-0-1.nip.io:8666

Password: 'admin'

### 5. log in to backstage

in your favorite browser:  http://backstage-127-0-0-1.nip.io:8666


### 4. Example App deployen

- Normal über git
- Über Backstage

### 5. Promote über die Stages

mit kargo

### delete k3d cluster

```
k3d cluster stop cnp-local-demo
k3d cluster delete cnp-local-demo
```


### Build suXess backstage container image and push it to our registry

build could take 1300 seconds and push could also take a lot of time
#TODO: image is very very big

```
git clone https://github.com/suxess-it/sx-backstage.git
cd sx-backstage
docker build -t sx-backstage:latest .
docker tag sx-backstage:latest ghcr.io/jkleinlercher/sx-backstage:latest
docker push ghcr.io/jkleinlercher/sx-backstage:latest
```