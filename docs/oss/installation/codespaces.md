# kubriX playground with GitHub Codespaces

You can create a kubriX playground by starting a GitHub Codespace in your browser. With that you have your own kubriX test environment within minutes without any installations on your local machine.
We are constantly adding new features to our kubriX playground with GitHub Codespaces, so stay tuned!

## To fork or not to fork

If you want to test onboarding your apps you need to write in this repository. Therefor you should fork [this repository](https://github.com/suxess-it/kubriX) into your GitHub account.

If you just want to have a look at the platform stack in a read-only mode, just use the original repository without forking.

## Start GitHub Codespace

You can start a GitHub Codespaces with the button below or this [link](https://github.com/codespaces/new/)

- Repository: this original kubriX repository or your fork
- Branch: main branch (or a feature branch if you want to test some special features)
- Dev container configuration: you can select which platform stack (brick) should get installed

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/)

<img width="991" height="706" alt="image" src="https://github.com/user-attachments/assets/e7ebe2ad-2724-4880-a7ba-40796df0dc9b" />

You will get a VSCode environment in your browser and additionally a KinD cluster and our platform stack gets installed during startup of the Codespace.

## Check the startup of the kubriX platform

After the Codespace gets created a KinD cluster gets installed and the whole platform stack gets installed. This takes up to 20 minutes. During this phase it is normal that some apps are degraded. This gets fixed in the installation process automatically.
You can follow this procedure in the log by pressing this link:

![image](https://github.com/user-attachments/assets/0c1d88cb-1f3a-43e6-964c-6066fdbdf564)

For further logs you also need to press CTRL+SHIFT+P and then type "Codespaces: View Creation Log":

![image](https://github.com/user-attachments/assets/38b59d91-ce63-4e3c-9f0d-68b48d039ea8)

Then you should see log messages in the "Terminal-View":

![image](https://github.com/user-attachments/assets/5552ef73-bce6-4129-a0b0-9d410ce47af5)

### Create GitHub OAuth App 

The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App as described in [this section](installation.md#create-github-oauth-app-and-set-secrets-in-vault).
 
## Accessing platform service consoles

In the "Ports-View" you will see different URLs for different platform services. When clicking on the "world" symbol you can open the URL in your browser and use the tools.

![image](https://github.com/user-attachments/assets/bad60f85-fb88-46cf-8d73-1090a9d61647)

You can already access the tools during installation of the platform stack, as soon as the tool is synced via ArgoCD and healthy. So especially opening ArgoCD UI during platform installation is very helpful to follow the installation process.

Needed credentials for the different tools are documented in [Logins](installation.md#login).

The commands can be executed in the Codespaces VSCode terminal. Just open a new "bash Terminal" and execute the commands above. Sometimes you need to permit copy/paste in your browser.

Also, at the end of the installation you get a summary of the URLs and credentials per tool. Unfortunately some infos are masked, we are working on that.

Log into kubriX portal (Backstage) with "Github".  Keycloak doesn't work inside GitHub Codespaces.

![image](https://github.com/user-attachments/assets/cd277d82-cda3-4144-82dd-9b218e2e6b6a)


## Onboarding teams and apps on the platform

In kubriX you can normally onboard new teams and onboard new applications via Backstage, our developer portal. However, there are several issues right now which prevents to do that in your forked repository. That's why we show you how you can do this directly via the gitops Repo. The positive effect is, you can look under the hood what really happens in the portal scaffolder templates ;) Of course our portal helps to onboard teams and apps easier. You will be able to test this also on GitHub Codespaces in the near future!

### Onboarding new teams via the kubriX platform gitops-Repo

After kubriX was installed sucessfully in Codespaces, edit this file in your Codespaces VSCode editor: `platform-apps/charts/team-onboarding/values-kind.yaml`

![image](https://github.com/user-attachments/assets/4c5c6fa5-967c-4c8c-a267-e0a5dc577006)

Add the following stanza to the file and replace YOUR_PRIVATE_ORGANIZATION with your private organization you created the fork (e.g. jkleinlercher).

```
teams:
  - name: team1
    sourceRepos:
      - '*'
    clusterResourceWhitelist:
      - group: ""
        kind: Namespace
      - group: kargo.akuity.io
        kind: Project
    appOfAppsRepo:
      repoURL: https://github.com/YOUR_PRIVATE_ORGANIZATION/team1-apps
      path: codespaces-apps
      revision: main
    multiStageKargoAppSet:
      organization: YOUR_PRIVATE_ORGANIZATION
```
Then commit and push the changes to your main branch:

```
git commit -a -m "onboard team1"
git push
```

The onboarded team has now two possibilities to onboard their apps. Option 1 is for teams which are familiar with ArgoCD application definitions and want a maximum of flexibility. Option 2 is more for dev teams which focus more on their application code and application specific K8s manifests but are not familiar with ArgoCD.

Option 1: create a new repo `https://github.com/YOUR_PRIVATE_ORGANIZATION/team1-apps` and create a new ArgoCD application definitions in this repo.

Option 2: create a new application gitops-repo in specified organization above with a specific pattern which matches specified [multiStageKargoAppSet](https://github.com/suxess-it/kubriX/blob/main/platform-apps/charts/team-onboarding/templates/appset-scm-multi-stage-kargo.yaml) ArgoCD ApplicationSet. This ApplicationSet is just an example and your platform engineers can define them on their own specific to your organizational needs. Attention: since ArgoCD ApplicationSet SCM Provider only scans repos in organizations and not in personal accounts, you need to create a repo in an organization. Maybe this gets fixed in the future by ArgoCD.

An example repo for Option 2 in our case is https://github.com/suxess-it/team-a-kcd-demo . It has a [app-stages.yaml](https://github.com/suxess-it/team-a-kcd-demo/blob/main/app-stages.yaml) and the corresponding values files. In the end this example creates three argocd applications and a Kargo project which does a gitops-promotion automatically.

After creating the new repo it can take up to 30 minutes that the ApplicationSet triggers a new API call to search for new Github repos. You can trigger this manually by deleting the applicationset-controller pod.

Details about our onboarding concept are explained in [App-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-apps.md) and [Team-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-teams.md ).

## Known issues

In local VSCode you can also use this devcontainers. If you want to rebuild them from scratch you need to do the following:

stop vscode

start vscode (but don't switch to devcontainer remote explorer)

then in vscode command (CTRL+SHIFT+P)

"dev containers: clean up dev containers"
"dev cotainers: clean up dev volume"
"rebuild without cache and reopen in container"
