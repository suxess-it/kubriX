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

6. Create Github OAuth App and set secrets in vault

    The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App in your [developer settings](https://github.com/organizations/YOUR-ORG/settings/applications).
    Click the button "New OAuth App".
    
    The URL of the Codespace has a random name and ID like `https://crispy-robot-g44qvrx9jpx29xx7.github.dev/`.
    Copy the hostname (codespace name) except ".github.dev" and set the URLs of the created OAuth App like this:

    - Homepage URL: `<copied hostname>-6691.app.github.dev`
    - Authorization callback URL: `<copied hostname>-6691.app.github.dev/api/auth/github`

    ![image](https://github.com/user-attachments/assets/fd513ff7-3501-4299-aab2-41feae1028bc)


    Use "Client ID" to define the variable "GITHUB_CLIENTID" in the step below. Generate a "Client secret" and use the secret to define the variable "GITHUB_CLIENTSECRET" in the step below.

    Then set GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App and set them in vault via kubectl/curl:

    ```
    export GITHUB_CLIENTID="<client-id-from-step-before>"
    export GITHUB_CLIENTSECRET="<client-secret-from-step-before>"
    export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
    export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
    curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request POST --data "{\"data\": {\"GITHUB_CLIENTSECRET\": \"${GITHUB_CLIENTSECRET}\", \"GITHUB_CLIENTID\":
    \"${GITHUB_CLIENTID}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base
    kubectl rollout restart deployment -n backstage sx-backstage
    ```

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage.127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd.127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo.127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana.127-0-0-1.nip.io | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey}' \| base64 -d` | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey}' \| base64 -d` |
| Keycloak    | https://keycloak.127-0-0-1.nip.io | admin | `kubectl get secret -n keycloak keycloak-admin -o=jsonpath='{.data.admin-password}' \| base64 -d` |
| FalcoUI    | https://falco.127-0-0-1.nip.io | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $1}'` | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $2}'` |

