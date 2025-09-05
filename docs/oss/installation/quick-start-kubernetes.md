# Quickstart demo stack on Kubernetes

With this step-by-step guide kubriX with its default demo stack gets deployed on your preferred Kubernetes cluster.

## Prerequisites

* check [Prerequisites](installation.md#-prerequisites)
* DNS-Provider which is supported by external-dns (see https://kubernetes-sigs.github.io/external-dns/latest/#new-providers )
* Kubernetes cluster with at least 4 CPU cores and 20 GB RAM

## Installation steps

1. create new empty customer repo on your Git-Server (GitLab, GitHub, Gitea, ...).
    We fully tested this with GitHub, but others should also work.

    IMPORTANT: the repo needs to be empty (also no initial README!!!)

2. create an access token for this new repo with write access
    
    Instead of a newly created access token you can also use your personal access tokens,
    but this is not recommended since your personal access token has probably more permissions than needed.

    If you create a fine-grained token on Github, these are the needed permissions:
   
<img width="1126" height="670" alt="github access token" src="https://github.com/user-attachments/assets/fc17742b-cda2-4d57-9cee-b33182706933" />

4. set the repo url and token in this variables like this:

    ```
    export KUBRIX_CUSTOMER_REPO="https://github.com/kubriX-demo/kubriX-demo-customerXY"
    export KUBRIX_CUSTOMER_REPO_TOKEN="blabla"
    ```

5. optional: set the DNS provider, which external-dns should connect to.

    default: ionos  
    supported: ionos, route53, stackit, cloudflare

    ```
    export KUBRIX_CUSTOMER_DNS_PROVIDER="ionos"
    ```

6. optional: set the domain, under which kubriX should be available.

    This domain will be used by external-dns. Your provider in step 4 needs to be able to manage this domain with the credentials set in step 8.

    ```
    export KUBRIX_CUSTOMER_DOMAIN="demo-johnny.kubrix.cloud"
    ```

    if this variable is not set, a subdomain of "kubrix.cloud" is randomly created (for example "demo-2faf23d.kubrix.cloud")

7. optional: set the kubrix target type which should be used

    ```
    export KUBRIX_CUSTOMER_TARGET_TYPE="DEMO-STACK"
    ```

    if this variable is not set, "DEMO-STACK" is used.

8. create a new Kubernetes cluster and be sure that kubectl is connected to it. check with `kubectl cluster-info`

9. provide external-dns secrets depending on your DNS provider

    __ionos__

    create a secret with your DNS api-key like this:

    ```
    kubectl create ns external-dns
    kubectl create secret generic ionos-credentials -n external-dns --from-literal=api-key='your-api-key'
    ```

    __aws__

    create a `credentials` file like this:

    ```
    [default]
    aws_access_key_id = your-key-id
    aws_secret_access_key = your-access-key
    ```

    and then create the secret on the K8s cluster based on this `credentials` file:
    ```
    kubectl create ns external-dns
    kubectl create secret generic -n external-dns sx-external-dns --from-file credentials
    ```

    __stackit__

    ```
    kubectl create ns external-dns
    kubectl create secret generic external-dns-webhook -n external-dns --from-literal=AUTH_TOKEN='your-auth-token'
    --from-literal=PROJECT_ID='your-project-id'
    ```

    __cloudflare__

    ```
    kubectl create ns external-dns
    kubectl create secret generic cloudflare-api-key -n external-dns --from-literal=apiKey='YOUR_API_TOKEN'
    ```

10. If you need to prepare something else on your cluster before kubriX gets installed, do this now.


11. Then run this command in your home directory in your linux bash:

    ```
    curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/bootstrap/bootstrap.sh | bash -s
    ```

    It will create a new kubriX repo based on your parameters and installs kubriX based on your created kubriX repo on your connected K8s cluster.


##  Next steps

* [Post-Installation steps](installation.md#-post-installation-steps)
