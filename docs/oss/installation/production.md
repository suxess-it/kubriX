# Production installation

> ⚠️ We highly recommend using **kubriX-prime** for production workload and professional services from [suXess-it](https://suxess-it.com/cloud-native/). Still, you can use kubriX OSS also for small production environments without special security or compliance needs at your own risk.

## Clone latest kubriX release to your git Repository

Create your own empty git repository on your VCS, clone it to your local machine and merge latest kubriX release into it:

```
git checkout main
git remote add kubriX-upstream https://github.com/suxess-it/kubriX.git
git fetch kubriX-upstream --tags
latestTag=$(git describe --tags "$(git rev-list --tags --max-count=1 --remotes=kubriX-upstream/main)"
git switch -c kubriX-upstream "${latestTag}"
git checkout main
git merge kubriX-upstream
```

## Integrating existing managed services

Think about how you want to deal with

- DNS resolution (kubriX works best with DNS provider supported by `external-secrets`)
- TLS certificates (kubriX uses `cert-manager` for creating certificates, typically via ACME protocol)
- Git-Server, Git-Server Repo/Group structure
- Helm- and Container-Registry
- Identity-Provider in your company which should get integrated with Keycloak (prime feature)
- Alerting-Receivers (Chat channels, E-Mails, .. any receivers supported by Alertmanager)
- Persistent Storage integration (S3,...)


## Preparing the .secrets files

All platform services get dynamically generated credentials during first installation according to [secret creation definition](/.secrets/.envoss.yaml). We highly recommend to not change this, unless you know what you do.

## Preparing values files

tbd

## Running the installer

tbd

## Post-Installation tasks

* [Post-Installation steps](installation.md#-post-installation-steps)


###  Next steps

* [Configuration Guide](../configuration/configuration.md) – customize kubriX for your needs
* [User Guide](../user-guide/user-guide.md) – start deploying apps




