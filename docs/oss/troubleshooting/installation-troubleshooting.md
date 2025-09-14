# Troubleshooting during Installation

## Restart Installation

If you had troubles during installation and want to restart the installation you can do this as follows:

Delete the kubrix-install job:

```
kubectl delete job kubrix-install-job -n kubrix-install
```

If you already have your own kubriX repo and don't want to bootstrap your repo from the upstream kubriX repo
set `KUBRIX_BOOTSTRAP` to `false`:

```
kubectl patch secret kubrix-install-secrets -n kubrix-install -p='{"stringData":{"KUBRIX_BOOTSTRAP": "false"}}'
```

If you do not want to regenerate the kubrix platform services credentials you should set `KUBRIX_GENERATE_SECRETS` to `false`:

```
kubectl patch secret kubrix-install-secrets -n kubrix-install -p='{"stringData":{"KUBRIX_GENERATE_SECRETS": "false"}}'
```

Then restart the installation by applying the manifests again:

```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/install-manifests.yaml
```

and view the logs again with this command:

```
kubectl logs -n kubrix-install -f "pod/$(kubectl get pod -n kubrix-install -l "job-name=kubrix-install-job" -o jsonpath='{.items[0].metadata.name}')" --all-containers=true
```

## Keycloak degraded

```
kubectl get applications -n argocd sx-keycloak -o yaml

[...]
      - group: jwt.vault.upbound.io
        hookPhase: Failed
        kind: AuthBackend
        message: |-
          create failed: async create failed: failed to create the resource: [{0 error writing to Vault: Error making API request.

          URL: POST http://sx-vault-active.vault.svc.cluster.local:8200/v1/sys/auth/oidc
          Code: 400. Errors:

          * path is already in use at oidc/  []}]
        name: oidc-backend
        namespace: keycloak
        status: Synced
        syncPhase: Sync
        version: v1alpha1
```

Reason:

The API to create an OIDC configuration wants to call the callback URL during creation.
This callback URL is the official keycloak URL. Sometimes, certificate for this URL is not yet valid (cert-manager or gardener cert-manager takes some time to create the official cert). Then vault creates the OIDC resource, but responds with an error.
The next time crossplane wants to create the oidc resource, it gets a "path is already in use" error.
Then you must manually delete the oidc resource:

```
kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}' | base64 -d
```

log in vault UI with this token and remove oidc in "access --> oidc --> ... "disable"

then delete the oidc crossplane resource

```
kubectl delete authbackend.jwt.vault.upbound.io/oidc-backend
```

and then argocd should sync again successful.
