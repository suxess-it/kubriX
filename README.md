# What is kubriX?

kubriX is a curated, opinionated and still very flexible platform stack build out of bricks for Kubernetes.

More informations on https://kubriX.io.

If you have ideas / questions, please [join our slack](https://join.slack.com/t/kubrix-platform/shared_invite/zt-2rc1yty2f-VTT3GOzUvo_k5hrgKbppKQ) or raise an issue.

# Test kubriX with GitHub Codespaces

You can create a kubriX test environment by starting a GitHub Codespace in your browser. With that you have your own kubriX test environment within minutes without any installations on your local machine.

## To fork or not to fork

If you want to test onboarding your apps you need to write in this repository. Therefor you should fork [this repository](https://github.com/suxess-it/sx-cnp-oss) into your GitHub account.

If you just want to have a look at the platform stack in a read-only mode, just use the original repository without forking.

## Start GitHub Codespace

You can then start a test environment with GitHub Codespaces in the original repository or in your personal fork. 

A KinD cluster and our platform stack gets installed during startup of the codespace,
so just try it with the button below and select the original or the fork:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/)

Don't forget to choose one of the kubrix stacks (delivery, observability, security, portal):
![image](https://github.com/user-attachments/assets/767d389e-fa03-4e5d-9df1-d270050afa0c)

You will get a VSCode environment in your browser.

### Create GitHub OAuth App 

The Backstage-Portal authenticates via GitHub OAuth App. Therefore you need to create one in your organization and use the Client-Secret and Client-ID during installation.

In your Github Organization for Backstage login: https://backstage.io/docs/auth/github/provider/

The `Homepage URL` and `Authorization callback URL` derive from the codespace URL.
You can simple open a terminal in your codespace and use the output of the following commands for the attributes:

![bash](https://github.com/user-attachments/assets/fd320ed9-aae3-46ce-85ab-b94b8a25a341)

- Homepage URL: `echo https://${CODESPACE_NAME}-6691.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}`
- Authorization callback URL: `echo https://${CODESPACE_NAME}-6691.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/api/auth/github`

Example:

![oauth](https://github.com/user-attachments/assets/a2e4f15e-8def-4340-bc39-e236d78be34f)

Use "Client ID" to define the variable "GITHUB_CLIENTID" in the step below.
Generate a "Client secret" and use the secret to define the variable "GITHUB_CLIENTSECRET" in the step below.

### Define some variables so the platform can access github

Define the variables below in the codespaces terminal. The GITHUB_TOKEN is used by kargo to write in your application gitops-Repos for git-promotion.

```
export GITHUB_CLIENTID=<value from steps above>
export GITHUB_CLIENTSECRET=<value from steps above>
export GITHUB_TOKEN=<your personal access token>
export GITHUB_APPSET_TOKEN=<github-pat-for-argocd-appsets-only-read-permissions-needed>
```
### Run installation script

Run the following script in your codespaces terminal to install the platform stack according to the kubriX stack you chose.

```
export TARGET_TYPE=KIND-DELIVERY
.devcontainer/install-platform-devcontainer.sh
```

A KinD cluster will get created and the platform stack will get installed.
This will take up to 20 minutes.

## Accessing platform service consoles

In the "Ports-View" you will see different URLs for different platform services. When clicking on the "world" symbol you can open the URL in your browser and use the tools.

![image](https://github.com/user-attachments/assets/bad60f85-fb88-46cf-8d73-1090a9d61647)

You can already access the tools during installation of the platform stack, as soon as the tool is synced via ArgoCD and healthy. So especially opening ArgoCD UI during platform installation is very helpful to follow the installation process.

Needed credentials for the different tools are:

| Tool     | Username | Password |
| -------- | ------- | ------- |
| Backstage  | via github | via github |
| ArgoCD | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo  | admin | - |
| Grafana    | admin | prom-operator |
| Keycloak   | admin | admin |
| FalcoUI    | admin | admin |

The password for ArgoCD can be found with the command above in the VSCode terminal. Just open a new "bash Terminal" and execute the command above.

Also, at the end of the installation you get a summary of the URLs and credentials per tool. Unfortunately some infos are masked, we are working on that.

## Onboarding teams and apps on the platform

Details about our onboarding concept are explained in [Onboarding](https://github.com/suxess-it/sx-cnp-oss/blob/main/backstage-resources/docs/ONBOARDING.md). There is also explained how to modify which gitops-Repos to onboard new teams and new applications.

Of course our portal helps to onboard teams and apps easier. However, currently we are facing some issues when login into the portal in a codespace via GitHub login. OAuth and Browser-Codespaces don't seem to work together at the moment. We will try to fix that in the future. In the meantime you can start your devcontainer in your local VSCode. There it should work.

## Known issues

In local VSCode you can also use this devcontainers. If you want to rebuild them from scratch you need to do the following:

stop vscode

start vscode (but don't switch to devcontainer remote explorer)

dann in vscode command (CTRL+SHIFT+P)

"dev containers: clean up dev containers"
"dev cotainers: clean up dev volume"
"rebuild without cache and reopen in container"

# Create a kubriX test environment on your local machine

## prereqs

k3d installed
kubectl installed

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
export GITHUB_CLIENTSECRET=<value from steps above>
export GITHUB_CLIENTID=<value from steps above>
export GITHUB_TOKEN=<your personal access token>
export GITHUB_APPSET_TOKEN=<github-pat-for-argocd-appsets-only-read-permissions-needed>
# set target type to the platform stack you want to install
export TARGET_TYPE=KIND-DELIVERY
# if a K3d cluster should get created:
export CREATE_K3D_CLUSTER=true
# if you want to test another branch, specify something else than main
export CURRENT_BRANCH=main
# set the current repository to the origin or to your fork
export CURRENT_REPOSITORY=suxess-it/sx-cnp-oss
```

## 2. install platform-stack

```
curl -L https://raw.githubusercontent.com/${CURRENT_REPOSITORY}/${CURRENT_BRANCH}/install-platform.sh | bash
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
k3d cluster stop cnp-local-demo
k3d cluster delete cnp-local-demo
```


# Old infos

## Auto-Installed Platform Stack in Codespace (DRAFT)

![image](https://github.com/user-attachments/assets/0c1d88cb-1f3a-43e6-964c-6066fdbdf564)

For further logs you also need to press CTRL+SHIFT+P and then type "Codespaces: View Creation Log":

![image](https://github.com/user-attachments/assets/38b59d91-ce63-4e3c-9f0d-68b48d039ea8)

Then you should see log messages in the "Terminal-View":

![image](https://github.com/user-attachments/assets/5552ef73-bce6-4129-a0b0-9d410ce47af5)
