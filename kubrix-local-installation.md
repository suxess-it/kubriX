# Create a kubriX test environment on your local machine

#### Attention! We will probably skip support for K3d cluster in a local environment in the future. We use KinD in our pipeline and also on local envs and we believe we should focus on one dev environment and keep this very stable. If you still need K3d, just please open an issue.

## prereqs

k3d or kind installed
kubectl installed

### installing KinD

Install kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

Create kind cluster
````
kind create cluster --name kubrix-local-demo --config .github/kind-config.yaml
````

### mkcert

```
curl -L -O https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
mv mkcert-v1.4.4-linux-amd64 ~/bin/mkcert
chmod u+x ~/bin/mkcert
```

install the CA of mkcert in your OS truststore: https://docs.kubefirst.io/k3d/quick-start/install#install-the-ca-certificate-authority-of-mkcert-in-your-trusted-store

### create GitHub OAuth App 

in your Github Organization for Backstage login: https://backstage.io/docs/auth/github/provider/

- Homepage URL: https://backstage-127-0-0-1.nip.io
- Authorization callback URL: https://backstage-127-0-0-1.nip.io/api/auth/github

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App for the following environment variables in step 1

## 1. define some variables for the installation

For the installation some variables are needed:

```
# Github clientsecret and clientid from GitHub OAuth App for Backstage
export KUBRIX_GITHUB_CLIENTSECRET=<value from steps above>
export KUBRIX_GITHUB_CLIENTID=<value from steps above>
# Github token Backstage uses to get the catalog yaml form github
export KUBRIX_GITHUB_TOKEN=<your personal access token>
# Github token ArgoCD uses for the SCM Provider
export KUBRIX_GITHUB_APPSET_TOKEN=<github-pat-for-argocd-appsets-only-read-permissions-needed>
# set the current repository to the origin or to your fork
export KUBRIX_REPO=https://github.com/suxess-it/kubriX.git
# if you want to test another branch, specify something else than main
export KUBRIX_REPO_BRANCH=main
# username and password to access kubriX git repository within ArgoCD
export KUBRIX_REPO_USERNAME=<kubrix-repo-username>
export KUBRIX_REPO_PASSWORD=<kubrix-repo-password-or-personal-access-token>
export KUBRIX_TARGET_TYPE=KIND-DELIVERY
# if a K3d cluster should get created:
export KUBRIX_CREATE_K3D_CLUSTER=true
```

## 2. install platform-stack

clone the upstream repo (or your personal fork) and optionally switch to specific branch

```
git clone ${KUBRIX_REPO}
# change to repo directory (if it is something else then kubriX, please change)
cd kubriX
checkout ${KUBRIX_REPO_BRANCH}
```

and install specific stack

```
./install-platform.sh
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

## 3. log in to the tools

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage-127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd-127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo-127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana-127-0-0-1.nip.io | admin | prom-operator |
| Keycloak    | https://keycloak-127-0-0-1.nip.io | admin | admin |
| FalcoUI    | https://falco-127-0-0-1.nip.io | admin | admin |

## 4. kubecost

initialization need some minutes until values are visible in UI - https://kubecost-127-0-0-1.nip.io/overview

## 5. keycloak

depending on your hardware it needs some minutes until keycloak is running 

## 6. Onboard teams and applications

In our [Onboarding-Documentation](https://github.com/suxess-it/sx-cnp-oss/blob/main/backstage-resources/docs/ONBOARDING.md) we explain how new teams and apps get onboarded on the platform in a gitops way.

## 7. Promote apps with Kargo

tbd

## delete k3d cluster

```
k3d cluster stop kubrix-local-demo
k3d cluster delete kubrix-local-demo
```
