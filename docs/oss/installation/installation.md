# Installation

## 📦 Introduction

This guide will walk you through installing **kubriX** in different environments - from quick local demos to production-ready clusters.

kubriX is modular by design, so you can start small and scale as your needs grow.  
Whether you’re exploring kubriX for the first time or deploying for team use, you’ll find the right path here.

---

## ✅ Prerequisites

Before installing kubriX, make sure you have:

- **Kubernetes**: v1.26+ (tested on KinD, K3s, EKS, AKS, GKE, and on-prem)
- **Command-line tools**:
  - [`kubectl`](https://kubernetes.io/docs/tasks/tools/) – Kubernetes CLI
  - [`helm`](https://helm.sh/) – Helm package manager
  - [`git`](https://git-scm.com/) – Version control
  - [`jq`](https://jqlang.org/download/) – json processor
  - [`yq`](https://github.com/mikefarah/yq?tab=readme-ov-file#install) – yaml processor
  - [`docker`](https://www.docker.com/) – Container runtime (for local installs only)
  - [`mkcert`](https://github.com/FiloSottile/mkcert) - tool for making locally-trusted development certificates (for local installs only)
  - [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries) - create a Kubernetes in Docker (for local installs only)

- **Cluster resources**:
  - Minimum: 4 CPU cores, 16 GB RAM, 20 GB storage
  - Recommended for production: 8+ CPU cores, 20 GB+ RAM
- Network connectivity to pull container images and helm charts from public repositories

> 💡 **Info:** completely air-gapped day-1 installations are not supported yet, but you can customize kubriX on day-2 to support air-gapped environments.

---

## 🛤 Choose Your Installation Path

| Environment | Goal | Install Guide |
|-------------|------|---------------|
| **GitHub Codespaces (Experimental)** | Explore kubriX instantly in your browser | [Codespaces Installation](codespaces.md) |
| **Local KinD** | Try kubriX quickly on your laptop | [Demo-Stack local KinD](kind.md) |
| **Demo Kubernetes Cluster** | Test a demo stack on a K8s cluster on your preferred cloud provider| [Demo-Stack on Kubernetes](quick-start-kubernetes.md)
| **Production Kubernetes Cluster** | Set up kubriX for productive team use | [Production Installation](production.md) |

> 💡 **Tip:** If you’re unsure where to start, try the **KinD installation** - it’s the fastest way to get kubriX running locally.

---

## ⚠️ Troubleshooting Installation

If you run into issues during setup, please see our [Troubleshooting Installation Guide](../troubleshooting/installation-troubleshooting.md) for common problems and solutions.

---

## 🔑 Post-Installation Steps

### Create Github OAuth App and set secrets in vault

  The Platform-Portal authenticates via GitHub OAuth App. Therefore you need to create a OAuth App in your [developer settings](https://github.com/organizations/YOUR-ORG/settings/applications).
  Click the button "New OAuth App".

  **For Github Codespaces**:

  The URL of the Codespace has a random name and ID like `https://crispy-robot-g44qvrx9jpx29xx7.github.dev/`. Copy the hostname (codespace name) except ".github.dev" and set the URLs of the created OAuth App like this:

  - Homepage URL: `<copied hostname>-6691.app.github.dev`
  - Authorization callback URL: `<copied hostname>-6691.app.github.dev/api/auth/github`

  **For local KinD Cluster**:  

  - Homepage URL: `https://backstage.127-0-0-1.nip.io`
  - Authorization callback URL: `https://backstage.127-0-0-1.nip.io/api/auth/github`

  **For remote Kubernetes Cluster**:  

  - Homepage URL and Authorization callback URL must match "https://backstage.${KUBRIX_CUSTOMER_DOMAIN}"


  Example:
  - Homepage URL: `backstage.demo-johnny.kubrix.cloud`
  - Authorization callback URL: `backstage.demo-johnny.kubrix.cloud/api/auth/github`

  <img width="549" height="638" alt="image" src="https://github.com/user-attachments/assets/2bed4a26-8990-49ab-afaf-2daaf0138261" />

  After clicking "Register application", click on "Generate a new client secret".

  <img width="1035" height="550" alt="image" src="https://github.com/user-attachments/assets/df3c94da-10e2-4315-8411-e1fa5c282ff8" />

  Use the value of the "Client ID" for the variable `GITHUB_CLIENTID` in the step below. 
  Use the generated client secret as the value for the variable `GITHUB_CLIENTSECRET` in the step below.

  Then set GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App and set them in vault via kubectl/curl:

  ```
  export GITHUB_CLIENTID="<client-id-from-step-before>"
  export GITHUB_CLIENTSECRET="<client-secret-from-step-before>"
  export VAULT_HOSTNAME=$(kubectl get ingress -o jsonpath='{.items[*].spec.rules[*].host}' -n vault)
  export VAULT_TOKEN=$(kubectl get secret -n vault vault-init -o=jsonpath='{.data.root_token}'  | base64 -d)
  curl -k --header "X-Vault-Token:$VAULT_TOKEN" --request PATCH --header "Content-Type: application/merge-patch+json" --data "{\"data\": {\"GITHUB_CLIENTSECRET\": \"${GITHUB_CLIENTSECRET}\", \"GITHUB_CLIENTID\": \"${GITHUB_CLIENTID}\"}}" https://${VAULT_HOSTNAME}/v1/kubrix-kv/data/portal/backstage/base
  kubectl delete externalsecret -n backstage sx-cnp-secret
  kubectl rollout restart deployment -n backstage sx-backstage
  ```

### Define user entities in backstage

  Before users can login via GitHub in backstage, there needs to be a matching User entity in your own kubriX repo in `backstage-resources/entities/all.yaml`

  ```
  apiVersion: backstage.io/v1alpha1
  kind: User
  metadata:
    name: <github-user>
  spec:
    profile:
      displayName: <github-user>
      email: guest@example.com
      picture: https://api.dicebear.com/9.x/adventurer-neutral/svg
    memberOf: [kubrix]
  ```

### Login

When kubriX installed sucessfully you can access the platform services via these URLs and login with these credentials:

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://backstage.127-0-0-1.nip.io | via github | via github |
| ArgoCD | https://argocd.127-0-0-1.nip.io/ | admin | `kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' \| base64 -d` |
| Kargo | https://kargo.127-0-0-1.nip.io     | admin | - |
| Grafana    | https://grafana.127-0-0-1.nip.io | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.userKey}' \| base64 -d` | `kubectl get secret -n grafana grafana-admin-secret -o=jsonpath='{.data.passwordKey}' \| base64 -d` |
| Keycloak    | https://keycloak.127-0-0-1.nip.io | admin | `kubectl get secret -n keycloak keycloak-admin -o=jsonpath='{.data.admin-password}' \| base64 -d` |
| FalcoUI    | https://falco.127-0-0-1.nip.io | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $1}'` | `kubectl get secret -n falco falco-ui-creds -o=jsonpath='{.data.FALCOSIDEKICK_UI_USER}' \| base64 -d \| awk -F: '{print $2}'` |

### Verify installation

Check if all ArgoCD applications are synced and healthy:

```
kubectl get applications -n argocd
```

> 🐞 **Known issue:** The application `sx-bootstrap-app` can be `OutOfSync` periodically due to the sub-application `sx-kyverno`.  
This will get fixed with https://github.com/suxess-it/kubriX/issues/1406

###  Next steps

* [Configuration Guide](../configuration/configuration.md) – customize kubriX for your needs
* [User Guide](../user-guide/user-guide.md) – start deploying apps

## 🩺 Troubleshooting Installation

If something goes wrong:

Verify if all apps are `Synced` and `Healthy`:

```
kubectl get applications -n argocd
```

Check if all pods are running:

```
kubectl get pods -A
```

Check logs of the unhealthy apps and pods:

```
kubectl logs -n <namespace> <pod-name>
```

> 💡 **Tips:** Try [K8sGPT](https://k8sgpt.ai/) to analyze your environment. We will integrate this tool in the future probably also in kubriX.

Consult the [Troubleshooting Installation Guide](../troubleshooting/installation-troubleshooting.md) for common fixes.

## 🗑 Uninstalling kubriX

### local KinD cluster

Delete your local KinD cluster:

```
kind delete cluster --name kubrix-local-demo
```

### Remote Kubernetes cluster

Delete your remote Kubernetes cluster via your cloud providers APIs.

### Delete kubriX gitops repo

Also delete your created kubriX gitops repository you defined in variable `KUBRIX_CUSTOMER_REPO` on your Git-Server.


## 📂 Installation Guides

* [Codespaces Installation](codespaces.md)
* [Demo-Stack local KinD](kind.md)
* [Demo-Stack Remote Kubernetes](quick-start-kubernetes.md)
* [Production Kubernetes Installation](production.md)
