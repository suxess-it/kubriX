# Quickstart kubriX on a local KinD cluster

With this step-by-step guide kubriX with its default stack gets deployed on your local KinD cluster.

## Prerequisites

* check [Prerequisites](installation.md#-prerequisites)

## Installation steps

1. create new empty customer repo on your Git-Server (GitLab, GitHub, Gitea, ...).
    We fully tested this with GitHub, but others should also work.

    IMPORTANT: the repo needs to be empty (also no initial README!!!)

2. create an access token for this new repo with write access
    
    Instead of a newly created access token you can also use your personal access tokens,
    but this is not recommended since your personal access token has probably more permissions than needed.

    ![image](../../img/github_token.png)

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

##  Next steps

* [Post-Installation steps](installation.md#-post-installation-steps)

