# What is kubriX?

kubriX is a curated, opinionated and still very flexible platform stack build out of bricks for Kubernetes.

More informations on https://kubriX.io.

If you have ideas / questions, please [join our slack](https://join.slack.com/t/kubrix-platform/shared_invite/zt-2rc1yty2f-VTT3GOzUvo_k5hrgKbppKQ) or raise an issue.

# kubriX playground with GitHub Codespaces

You can create a kubriX playground by starting a GitHub Codespace in your browser. With that you have your own kubriX test environment within minutes without any installations on your local machine.

## To fork or not to fork

If you want to test onboarding your apps you need to write in this repository. Therefor you should fork [this repository](https://github.com/suxess-it/sx-cnp-oss) into your GitHub account.

If you just want to have a look at the platform stack in a read-only mode, just use the original repository without forking.

### Create GitHub OAuth App 

The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App in your [delevoper settings](https://github.com/settings/developers) and use the Client-Secret and Client-ID during installation or GitHub Codespace creation.

The `Homepage URL` and `Authorization callback URL` derive from the codespace URL. Since the codespace URL is not known yet, you can set some dummy values. We will correct this in the next steps.

![image](https://github.com/user-attachments/assets/fd513ff7-3501-4299-aab2-41feae1028bc)

Use "Client ID" to define the variable "KUBRIX_GITHUB_CLIENTID" in the step below.
Generate a "Client secret" and use the secret to define the variable "KUBRIX_GITHUB_CLIENTSECRET" in the step below.

## Start GitHub Codespace

You can start a GitHub Codespaces with the button below or this [link](https://github.com/codespaces/new/)

- Repository: this original repository or your fork
- Branch: main branch (or a feature branch if you want to test some special features)
- Dev container configuration: you can select which platform stack (brick) should get installed
- Recommended Secrets:
  - KUBRIX_GITHUB_CLIENTID: "Client ID" of your OAuth App in the variable
  - KUBRIX_GITHUB_CLIENTSECRET: "Client secret" of your OAuth App in the variable
  - KUBRIX_GITHUB_TOKEN: a Personal Access Token for Github to read files from the origin repo
  - KUBRIX_GITHUB_APPSET_TOKEN: a Personal Access Token for Github to read repositories in your organization (for ArgoCD AppSet SCM Generator)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/)

![image](https://github.com/user-attachments/assets/ca473d8c-6bf2-4687-9b10-88dd29843860)


You will get a VSCode environment in your browser and additionally a KinD cluster and our platform stack gets installed during startup of the Codespace.

## Correct 'Homepage URL' and 'Authorization callback URL' in your OAuth App

The URL of the new Codespace has a random name and ID like `https://crispy-robot-g44qvrx9jpx29xx7.github.dev/`.
Copy the hostname (codespace name) except ".github.dev" and fix the URLs of the created OAuth App like this:

- Homepage URL: `<copied hostname>-6691.app.github.dev`
- Authorization callback URL: `<copied hostname>-6691.app.github.dev/api/auth/github`

and click on "Update application"
Example:

![image](https://github.com/user-attachments/assets/7e8e51c7-bd1c-4c5b-b21f-c8abe37a47ed)

## Check the startup of the kubriX platform

After the Codespace gets created a KinD cluster gets installed and the whole platform stack gets installed. This takes up to 20 minutes. During this phase it is normal that some apps are degraded. This gets fixed in the installation process automatically.
You can follow this procedure in the log by pressing this link:

![image](https://github.com/user-attachments/assets/0c1d88cb-1f3a-43e6-964c-6066fdbdf564)

For further logs you also need to press CTRL+SHIFT+P and then type "Codespaces: View Creation Log":

![image](https://github.com/user-attachments/assets/38b59d91-ce63-4e3c-9f0d-68b48d039ea8)

Then you should see log messages in the "Terminal-View":

![image](https://github.com/user-attachments/assets/5552ef73-bce6-4129-a0b0-9d410ce47af5)

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

Log into kubriX portal (Backstage) with "Github".  Keycloak doesn't work inside GitHub Codespaces.

![image](https://github.com/user-attachments/assets/cd277d82-cda3-4144-82dd-9b218e2e6b6a)


## Onboarding teams and apps on the platform

Details about our onboarding concept are explained in [Onboarding](https://github.com/suxess-it/sx-cnp-oss/blob/main/backstage-resources/docs/ONBOARDING.md). There is also explained how to modify which gitops-Repos to onboard new teams and new applications.

Of course our portal helps to onboard teams and apps easier. You will be able to test this also on GitHub Codespaces in the near future!

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



