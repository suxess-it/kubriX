# cnp local demo environment

## how to set it up

### prereqs

k3d installed
kubectl installed

#### mkcert

```
curl -L -O https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
mv mkcert-v1.4.4-linux-amd64 ~/bin/mkcert
chmod u+x ~/bin/mkcert
```

install the CA of mkcert in your OS truststore: https://docs.kubefirst.io/k3d/quick-start/install#install-the-ca-certificate-authority-of-mkcert-in-your-trusted-store

#### create GitHub OAuth App 

in your Github Organization for Backstage login: https://backstage.io/docs/auth/github/provider/

- Homepage URL: https://backstage-127-0-0-1.nip.io
- Authorization callback URL: https://backstage-127-0-0-1.nip.io/api/auth/github

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App for the following environment variables in step 1

### 1. define some variables so the platform can access github

```
export GITHUB_CLIENTSECRET=<value from steps above>
export GITHUB_CLIENTID=<value from steps above>
export GITHUB_TOKEN=<your personal access token>
```

### 2. create k3d cluster

```
export TARGET_TYPE=K3D
# if you use a KIND cluster you should set:
# export TARGET_TYPE=KIND
curl -L https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/install-platform.sh | bash
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
* promtail
* loki
* tempo
* kubecost
* keycloak
* external-secret-operator
* falco

### 3. log in to the tools

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage-127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd-127-0-0-1.nip.io/ | admin | admin |
| Kargo | https://kargo-127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana-127-0-0-1.nip.io | admin | prom-operator |
| Keycloak    | https://keycloak-127-0-0-1.nip.io | admin | admin |
| FalcoUI    | https://falco-127-0-0-1.nip.io | admin | admin |

### 4. Example App deployen

Create a demo-app and kargo pipeline for this demo app:
```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/team-apps/team-apps-k3d.yaml -n argocd
```

The demo-app gitops-repo is in `https://github.com/suxess-it/sx-cnp-oss-demo-app`
Via an appset 3 stages get deployed and are managed in a Kargo-Project: `https://kargo-127-0-0-1.nip.io/project/kargo-demo-app`

kargo needs to write to your gitops repo to promote changed from one stage to another. in this demo we use the [suxess-it demo-app](https://github.com/suxess-it/sx-cnp-oss-demo-app).

```
export GITHUB_USERNAME=<your github handle>
export GITHUB_PAT=<your personal access token>
kubectl create secret generic git-demo-app -n kargo-demo-app --from-literal=repoURL=https://github.com/suxess-it/sx-cnp-oss-demo-app --from-literal=username=${GITHUB_USERNAME} --from-literal=password=${GITHUB_PAT}
kubectl label secret git-demo-app -n kargo-demo-app kargo.akuity.io/cred-type=git
```

URLs for stages:

- test: http://test-demo-app-127-0-0-1.nip.io
- qa: http://qa-demo-app-127-0-0-1.nip.io
- prod: http://prod-demo-app-127-0-0-1.nip.io

### 5. Promote über die Stages

mit kargo

### 6. kubecost

initialization need some minutes until values are visible in UI - https://kubecost-127-0-0-1.nip.io/overview

### delete k3d cluster

```
k3d cluster stop cnp-local-demo
k3d cluster delete cnp-local-demo
```


### Build suXess backstage container image and push it to our registry

#### automatically with Github Actions

Workflow-File: https://github.com/suxess-it/sx-backstage/blob/feat/cnp-local-demo-jokl/.github/workflows/docker-image.yaml

#### manually on local machine
build could take 1300 seconds and push could also take a lot of time
```
git clone https://github.com/suxess-it/sx-backstage.git
cd sx-backstage
git switch feat/cnp-local-demo-jokl
# modify code, test, commit
docker build -t sx-backstage:latest .
docker tag sx-backstage:latest ghcr.io/suxess-it/sx-backstage:latest
docker push ghcr.io/suxess-it/sx-backstage:latest
kubectl rollout restart deploy/sx-backstage -n backstage
```
