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


| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage.127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd.127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo.127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana.127-0-0-1.nip.io | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey}' | base64 -d` | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey}' | base64 -d` |
| Keycloak    | https://keycloak.127-0-0-1.nip.io | `kubectl get secret -n keycloak keycloak-admin -o=jsonpath='{.data.admin-password}' | base64 -d` | admin |
| FalcoUI    | https://falco.127-0-0-1.nip.io | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' | base64 -d | awk -F: '{print $1}'` | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' | base64 -d | awk -F: '{print $2}' |

