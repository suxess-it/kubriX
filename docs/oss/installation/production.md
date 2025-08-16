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

Think about how you deal with

- DNS resolution (kubriX works best with DNS provider supported by `external-secrets`)
- TLS certificates (kubriX uses `cert-manager` for creating certificates, typically via ACME protocol)
- 

## Preparing the .secrets files

tbd

## Preparing values files

tbd

## Running the installer

tbd

## Post-Installation tasks

tbd 


###  Next steps

* [Configuration Guide](../configuration/configuration.md) – customize kubriX for your needs
* [User Guide](../user-guide/user-guide.md) – start deploying apps




