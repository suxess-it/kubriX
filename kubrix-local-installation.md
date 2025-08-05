# Create a kubriX test environment on your local machine

## prereqs

- kind
- yq
- jq
- helm
- kubectl

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

## 1. define some variables for the installation

For the installation some variables are needed:

```
# Github token Backstage uses to get the catalog yaml form github
export KUBRIX_BACKSTAGE_GITHUB_TOKEN=<your personal access token>
# Github token ArgoCD uses for the SCM Provider
export KUBRIX_ARGOCD_APPSET_TOKEN=<github-pat-for-argocd-appsets-only-read-permissions-needed>
# Kargo Git Promotion credentials
export KUBRIX_KARGO_GIT_USERNAME=<username-for-kargo-git-promotion>
export KUBRIX_KARGO_GIT_PASSWORD=<username-for-kargo-git-promotion>
# set the current repository to the origin or to your fork
export KUBRIX_REPO=https://github.com/suxess-it/kubriX.git
# if you want to test another branch, specify something else than main
export KUBRIX_REPO_BRANCH=main
# username and password to access kubriX git repository within ArgoCD
export KUBRIX_REPO_USERNAME=<kubrix-repo-username>
export KUBRIX_REPO_PASSWORD=<kubrix-repo-password-or-personal-access-token>
export KUBRIX_TARGET_TYPE=KIND-DELIVERY
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
| Backstage  | https://backstage.127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd.127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo.127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana.127-0-0-1.nip.io | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey}' \| base64 -d` | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey}' \| base64 -d` |
| Keycloak    | https://keycloak.127-0-0-1.nip.io | admin | `kubectl get secret -n keycloak keycloak-admin -o=jsonpath='{.data.admin-password}' \| base64 -d` |
| FalcoUI    | https://falco.127-0-0-1.nip.io | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $1}'` | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $2}'` |

## 4. create GitHub OAuth App 

The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App in your [developer settings](https://github.com/organizations/YOUR-ORG/settings/applications).
Click the button "New OAuth App".

- Homepage URL: https://backstage-127-0-0-1.nip.io
- Authorization callback URL: https://backstage-127-0-0-1.nip.io/api/auth/github

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App and set them in vault via kubectl/curl:

```
export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request POST --data "{\"data\": {\"GITHUB_CLIENTSECRET\": \"${GITHUB_CLIENTSECRET}\", \"GITHUB_CLIENTID\":
\"${GITHUB_CLIENTID}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base
kubectl rollout restart deployment -n backstage sx-backstage
```



## 5. kubecost

initialization need some minutes until values are visible in UI - https://kubecost-127-0-0-1.nip.io/overview

## 6. keycloak

depending on your hardware it needs some minutes until keycloak is running 

## 7. Onboard teams and applications

In our [App-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-apps.md) and [Team-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-teams.md ) we explain how new teams and apps get onboarded on the platform in a gitops way.

## 7. Promote apps with Kargo

tbd

## delete kind cluster

```
kind delete cluster --name kubrix-local-demo
```
