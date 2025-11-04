# Production installation

> ⚠️ We highly recommend using **kubriX-prime** for production workload and professional services from [suXess-it](https://suxess-it.com/cloud-native/). Still, you can use kubriX OSS also for small production environments without special security or compliance needs at your own risk.

## Bootstrap automation VS manual setup

Many of the next steps will be probably automated in the future by the bootstrap automation you already use in [Quickstart Kubernetes Installation](quick-start-kubernetes.md). However, with this tutorial we want to show you how you can customize your kubriX installation in the most flexible way.

## Clone latest kubriX release to your git Repository

Create your own empty git repository on your VCS, clone it to your local machine and merge latest kubriX release into it:

```bash
git clone <your-repo>
cd <your-repo-directory>
git remote add kubriX-upstream https://github.com/suxess-it/kubriX.git
git fetch kubriX-upstream --tags
latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1 --remotes=kubriX-upstream/main)"
git switch -c kubriX-upstream "${latestTag}"
git checkout --orphan kubriX-downstream
git push --set-upstream origin publish:main
git checkout main
git pull
```

## Integrating existing managed services

Think about how you want to deal with

- DNS resolution (kubriX works best with DNS provider supported by `external-dns`)
- TLS certificates (kubriX uses `cert-manager` for creating certificates, typically via ACME protocol)
- Persistent Storage integration (S3 for observability data and backups, ...)
- Git-Server, Git-Server Repo/Group structure
- Helm- and Container-Registry
- Identity-Provider in your company which should get integrated with Keycloak (prime feature)
- Alerting-Receivers (Chat channels, E-Mails, .. any receivers supported by Alertmanager)

## Preparing the .secrets files

All platform services get dynamically generated credentials during first installation according to `.secrets/.envoss.yaml`. We highly recommend to not change this, unless you know what you do.

## Preparing values files

kubriX consists in its core of an ArgoCD AppOfApps definition - called `sx-bootstrap-app` - which defines the platform services. It is defined in a values file in the `platform-apps/target-chart` directory. In the installer in the next step uses `KUBRIX_TARGET_TYPE` variable, which references to this part if the file `values-<target-type>.yaml`.

The `.default.valueFiles` list defines the default values files with which each platform app chart should get deployed.

The `.applications` list defines all platform apps, which should get deployed.

```yaml
default:
  valueFiles:
  - values-kubriX-hub-prod-aws.yaml

applications:

  - name: ingress-nginx
    annotations:
      argocd.argoproj.io/sync-wave: "-11"

  - name: cert-manager
    annotations:
      argocd.argoproj.io/sync-wave: "-10"
```

You can set several attributes per application, which you can see in the example files.
These apps reference to directories in the `platform-apps/charts/` directory.

> 🔭 **Future Outlook**: we will probably introduce also an attribute `repo` so platform apps can also live in different git/oci repositories.

Each platform app can then get customized via values files in `platform-apps/charts/<app>/` directory. kubriX delivers out-of-the-box values for different flavors which you can extend or change for your needs.

After customizing all values files, commit and push your changes to your own kubriX gitops repo in the branch you want to sync to this cluster in the future.

> 💡 **Tip**: We recommend stage specific branches, which get merged from main. Described in [storage options - stage specific branches](https://docs.kargo.io/user-guide/patterns/#storage-options)

## Running the installer

Create a `kubrix-install` Namespace and a Secret `kubrix-installer-secrets` to configure the installer.  
The values of `KUBRIX_REPO` and `KUBRIX_REPO_PASSWORD` need to be set to your newly created kubriX Git repo in step 1 and the access token you created in step 2.

```
export KUBRIX_REPO="https://github.com/kubriX-demo/kubriX-demo-customerXY"
export KUBRIX_REPO_PASSWORD="your-read-write-access-token"
export KUBRIX_GIT_USER_NAME="your-github-username"

kubectl create ns kubrix-install
kubectl create secret generic kubrix-install-secrets -n kubrix-install \
  --from-literal KUBRIX_REPO=${KUBRIX_REPO} \
  --from-literal KUBRIX_REPO_PASSWORD=${KUBRIX_REPO_PASSWORD} \
  --from-literal KUBRIX_GIT_USER_NAME=${KUBRIX_GIT_USER_NAME} \
  --from-literal KUBRIX_TARGET_TYPE=<your-target-type>
  --from-literal KUBRIX_BACKSTAGE_GITHUB_TOKEN=<your-repo-read-access-token>
  --from-literal KUBRIX_INSTALLER=true
```

Then apply the installer manifests:

```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/install-manifests.yaml
```

These manifests will create a Kubernetes Job which creates a clone of the upstream kubriX OSS repo with some customizations in your newly created repo and starts the installation on your Kubernetes cluster.

This could take up to 30 minutes, depending on the compute resources of the Kubernetes cluster.

You can watch the logs of the job with
```
kubectl logs -n kubrix-install -f "pod/$(kubectl get pod -n kubrix-install -l "job-name=kubrix-install-job" -o jsonpath='{.items[0].metadata.name}')" --all-containers=true
```

Especially Keycloak could take a while,
since there are many resources created via Crossplane in different ArgoCD sync-waves.
After 300 seconds the sync process gets terminated and restarted. This could happend sometimes and is not always indicating a problem.
Also, sometimes the Keycloak app could be in temporary `Degraded` state during installation, but gets `Healthy` afterwards.

## Post-Installation tasks

* [Post-Installation steps](installation.md#-post-installation-steps)


###  Next steps

* [Configuration Guide](../configuration/configuration.md) – customize kubriX for your needs
* [User Guide](../user-guide/user-guide.md) – start deploying apps




