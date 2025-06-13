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

Create kind cluster
````
kind create cluster --name kubrix-local-demo --config .github/kind-config.yaml
````

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
    export KUBRIX_CUSTOMER_REPO_TOKEN="blabla"
    export KUBRIX_CUSTOMER_TARGET_TYPE="KIND-DELIVERY"
    ```

4. create a new KinD cluster and be sure that kubectl is connected to it. check with `kubectl cluster-info`

5. Then run this command in your home directory in your linux bash:

    ```
    curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/bootstrap/bootstrap.sh | bash -s
    ```

It will create a new kubriX repo based on your parameters and installs kubriX based on your created kubriX repo on your connected K8s cluster.