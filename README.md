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

install the CA of mkcert in your OS truststore: https://docs.kubefirst.io/k3d/quick-start/install#install-the-ca-certificate-authority-of-mkcert-in-your-trusted-store


### 1. create k3d cluster

```
curl -L https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/install-k3d-cluster.sh | sh
```

With this command a new k3d cluster gets created.
A "bootstrap argocd" get's installed via helm.
A "boostrap-app" gets installed which references all other apps in the plattform-stack (app-of-apps pattern)
ArgoCD itself is also then managed by an argocd app.

The platform stack will be installed automagically ;)

* backstage
* argocd (managed by argocd)
* argo-rollouts
* kargo
* cert-manager
* crossplane
* kyverno
* prometheus
* grafana

### 2. wait until everything except backstage is app and running

wait until all pods are started:

```
watch kubectl get pods -A
```

wait until all apps are synced and healthy

```
watch kubectl get applications -n argocd
```

backstage is still progressing. 

### 3. log in to argocd

create secret

TODO: not secure, but due to https://github.com/suxess-it/sx-cnp-oss/issues/48
I apply a file because the bcrypt value with "kubectl create secret ... --from-literal" gets messed up
```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/platform-apps/charts/argocd/manual-secret/argocd-secret.yaml
```

in your favorite browser:  https://argocd-127-0-0-1.nip.io:8667/

if argocd says "server.secretkey" is missing, try

```
kubectl rollout restart deploy/argocd-server -n argocd
```

- Username: `admin`
- Password: `admin`

### 4. create Backstage secret manually

create some secrets manually first, which I didn't want to put in git.

create OAuth App on Github for Backstage login: https://backstage.io/docs/auth/github/provider/

- Homepage URL: https://backstage-127-0-0-1.nip.io:8667/
- Authorization callback URL: https://backstage-127-0-0-1.nip.io:8667/api/auth/github

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App for the following environment variables.

create ArgoCD Token for backstage:
```
argocd login argocd-127-0-0-1.nip.io:8667
argocd account get --account backstage
argocd account generate-token --account backstage

use output in variable
export ARGOCD_AUTH_TOKEN="argocd.token=<output from above>"
```

create Grafana ServiceAccount token for backstage:

```
ID=$( curl -k -X POST https://grafana-127-0-0-1.nip.io:8667/api/serviceaccounts --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage","role": "Viewer","isDisabled": false}' | jq -r .id )

export GRAFANA_TOKEN=$(curl -k -X POST https://grafana-127-0-0-1.nip.io:8667/api/serviceaccounts/${ID}/tokens --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage"}' | jq -r .key)
```


```
export GITHUB_CLIENTSECRET=<value from steps above>
export GITHUB_CLIENTID=<value from steps above>
export GITHUB_ORG=<your github handle>
export GITHUB_TOKEN=<your personal access token>
export K8S_SA_TOKEN=$( kubectl get secret backstage-locator -n backstage  -o jsonpath='{.data.token}' | base64 -d )
kubectl create secret generic -n backstage manual-secret --from-literal=GITHUB_CLIENTSECRET=${GITHUB_CLIENTSECRET} --from-literal=GITHUB_CLIENTID=${GITHUB_CLIENTID} --from-literal=GITHUB_ORG=${GITHUB_ORG} --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN} --from-literal=K8S_SA_TOKEN=${K8S_SA_TOKEN} --from-literal=ARGOCD_AUTH_TOKEN=${ARGOCD_AUTH_TOKEN} --from-literal=GRAFANA_TOKEN=${GRAFANA_TOKEN}
```

Restart backstage pod:

```
kubectl rollout restart deploy/sx-backstage -n backstage
```

### 5. log in to backstage

in your favorite browser:  https://backstage-127-0-0-1.nip.io:8667

### 6. log in to kargo

in your favorite browser:  https://kargo-127-0-0-1.nip.io:8667

Password: 'admin'

### 7. log in to grafana

in your favorite browser:  https://grafana-127-0-0-1.nip.io:8667

- Username: `admin`
- Password: `prom-operator`

### 8. Example App deployen

Create a demo-app and kargo pipeline for this demo app:
`kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/team-apps/team-apps-k3d.yaml -n argocd`

The demo-app gitops-repo is in `https://github.com/suxess-it/sx-cnp-oss-demo-app`
Via an appset 3 stages get deployed and are managed in a Kargo-Project: `https://kargo-127-0-0-1.nip.io:8667/project/kargo-demo-app`

kargo needs to write to your gitops repo to promote changed from one stage to another. in this demo we use the [suxess-it demo-app](https://github.com/suxess-it/sx-cnp-oss-demo-app).

```
export GITHUB_USERNAME=<your github handle>
export GITHUB_PAT=<your personal access token>
kubectl create secret generic git-demo-app -n kargo-demo-app --from-literal=type=git --from-literal=url=https://github.com/suxess-it/sx-cnp-oss-demo-app --from-literal=username=${GITHUB_USERNAME} --from-literal=password=${GITHUB_PAT}
kubectl label secret git-demo-app -n kargo-demo-app kargo.akuity.io/secret-type=repository
```

URLs for stages:

- test: http://test-demo-app-127-0-0-1.nip.io:8666/
- qa: http://qa-demo-app-127-0-0-1.nip.io:8666/
- prod: http://prod-demo-app-127-0-0-1.nip.io:8666/

### 9. Promote über die Stages

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
git switch feat/cnp-local-demo-jokl
docker build -t sx-backstage:latest .
docker tag sx-backstage:latest ghcr.io/suxess-it/sx-backstage:latest
docker push ghcr.io/suxess-it/sx-backstage:latest
```
