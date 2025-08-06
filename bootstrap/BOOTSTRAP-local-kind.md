# Bootstrap kubriX on a local KinD cluster

With this step-by-step guide kubriX with its default KIND-DELIVERY stack gets deployed on your local KinD cluster.

## Prerequisites

* kubectl
* kind
* mkcert
* jq
* yq

### installing KinD

Install kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

### mkcert

```
curl -L -O https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
mv mkcert-v1.4.4-linux-amd64 ~/bin/mkcert
chmod u+x ~/bin/mkcert
```

install the CA of mkcert in your OS truststore: https://docs.kubefirst.io/k3d/quick-start/install#install-the-ca-certificate-authority-of-mkcert-in-your-trusted-store


## Installation steps

1. create new empty customer repo on your Git-Server (GitLab, GitHub, Gitea, ...).
    We fully tested this with GitHub, but others should also work.

    IMPORTANT: the repo needs to be empty (also no initial README!!!)

2. create an access token for this new repo with write access
    
    Instead of a newly created access token you can also use your personal access tokens,
    but this is not recommended since your personal access token has probably more permissions than needed.

3. set the repo url and token in this variables like this and the kubriX stack which should get deployed:

    ```
    export KUBRIX_CUSTOMER_REPO="https://github.com/kubriX-demo/kubriX-demo-customerXY"
    export KUBRIX_CUSTOMER_REPO_TOKEN="your-read-write-access-token"
    export KUBRIX_CUSTOMER_TARGET_TYPE="DEMO-STACK"
    export KUBRIX_CUSTOMER_DOMAIN="127-0-0-1.nip.io"
    export KUBRIX_CUSTOMER_DNS_PROVIDER="none"
    export KUBRIX_CLUSTER_TYPE="KIND"
    ```

4. create a new KinD cluster and be sure that kubectl is connected to it. check with `kubectl cluster-info`

     You need to enable ingress on your KinD cluster so this config below should be used with `kind create cluster --name kubrix-local-demo --config kind-config.yaml`

        
     ```
     kind: Cluster
     apiVersion: kind.x-k8s.io/v1alpha4
     nodes:
     - role: control-plane
       kubeadmConfigPatches:
       - |
         kind: InitConfiguration
         nodeRegistration:
           kubeletExtraArgs:
             node-labels: "ingress-ready=true"
       extraPortMappings:
       - containerPort: 80
         hostPort: 80
         protocol: TCP
       - containerPort: 443
         hostPort: 443
         protocol: TCP
     ```

5. Then run this command in your home directory in your linux bash:

    ```
    curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/bootstrap/bootstrap.sh | bash -s
    ```

    It will create a new kubriX repo based on your parameters and installs kubriX based on your created kubriX repo on your local KinD cluster.
    This could take up to 30 minutes, depending how powerful your local environment is.

    Especially Keycloak could take a while,
    since there are many resources created via Crossplane in different ArgoCD sync-waves.  
    After 300 seconds the sync process gets terminated and restarted. This could happend sometimes and is not always indicating a problem.
    Also, sometimes the Keycloak app could be in temporary `Degraded` state during installation, but gets `Healthy` afterwards.

7. Create Github OAuth App and set secrets in vault

    The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App in your [developer settings](https://github.com/organizations/YOUR-ORG/settings/applications).
    Click the button "New OAuth App".
    
    - Homepage URL: https://backstage.127-0-0-1.nip.io
    - Authorization callback URL: https://backstage.127-0-0-1.nip.io/api/auth/github

    <img width="549" height="638" alt="image" src="https://github.com/user-attachments/assets/2bed4a26-8990-49ab-afaf-2daaf0138261" />

    After clicking "Register application", click on "Generate a new client secret".

    <img width="1035" height="550" alt="image" src="https://github.com/user-attachments/assets/df3c94da-10e2-4315-8411-e1fa5c282ff8" />

    Use the value of the "Client ID" for the variable `GITHUB_CLIENTID` in the step below. 
    Use the generated client secret as the value for the variable `GITHUB_CLIENTSECRET` in the step below.

    Then set GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App and set them in vault via kubectl/curl:

    ```
    export GITHUB_CLIENTID="<client-id-from-previous-step>"
    export GITHUB_CLIENTSECRET="<client-secret-from-previous-step>"
    export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
    export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
    curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request POST --data "{\"data\": {\"GITHUB_CLIENTSECRET\": \"${GITHUB_CLIENTSECRET}\", \"GITHUB_CLIENTID\": \"${GITHUB_CLIENTID}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base
    kubectl delete externalsecret -n backstage sx-cnp-secret
    kubectl rollout restart deployment -n backstage sx-backstage
    ```

When kubriX installed sucessfully you can access the platform services via these URLs and login with these credentials:

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage.127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd.127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo.127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana.127-0-0-1.nip.io | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey}' \| base64 -d` | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey}' \| base64 -d` |
| Keycloak    | https://keycloak.127-0-0-1.nip.io | admin | `kubectl get secret -n keycloak keycloak-admin -o=jsonpath='{.data.admin-password}' \| base64 -d` |
| FalcoUI    | https://falco.127-0-0-1.nip.io | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $1}'` | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $2}'` |


## Onboard teams and applications

In our [App-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-apps.md) and [Team-Onboarding-Documentation](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/onboarding-teams.md ) we explain how new teams and apps get onboarded on the platform in a gitops way.

## Promote apps with Kargo

Follow the [Promoting changes with Kargo](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/docs/onboarding/promoting-changes.md) documentation to walk through the use case how to move changes from test to production.

## Cleanup

Delete your local KinD cluster:

```
kind delete cluster --name kubrix-local-demo
```

Also delete your created kubriX gitops-Repo you defined in variable `KUBRIX_CUSTOMER_REPO` on your Git-Server.
