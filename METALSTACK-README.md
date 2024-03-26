# SX-CNP on Metalstack

## how to set it up

### prereqs

After creating a K8s cluster on https://console.metalstack.cloud/, copy the KUBECONFIG to your local machine to `~/.kube/metalstack-config ` and set the KUBECONFIG to this file.

```
export KUBECONFIG=~/.kube/metalstack-config 
```

### 1. install the platform stack as follows

```
curl -L https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/install-metalstack-cluster.sh | sh
```

With this command a "bootstrap argocd" get's installed via helm.
A "boostrap-app" gets installed which references all other apps in the plattform-stack (app-of-apps pattern)
ArgoCD itself is also then managed by an argocd app.

The platform stack will be installed automagically ;)

* backstage
* argocd (managed by argocd)
* argo-rollouts
* kargo
* cert-manager
* crossplane
* kyverno
* prometheus
* grafana

### 2. create DNS entries

Set the DNS Records in AWS Route53 to the Loadbalancer IP-Address of the K8s Cluster. The IP address is under "IP addresses" in the metalstack console.

- portal-metalstack.platform-engineer.cloud
- argocd-metalstack.platform-engineer.cloud
- kargo-metalstack.platform-engineer.cloud
- grafana-metalstack.platform-engineer.cloud

### 3. wait until everything except backstage is app and running

wait until all pods are started:

```
watch kubectl get pods -A
```

wait until all apps are synced and healthy

```
watch kubectl get applications -n argocd
```

backstage is still progressing. 

### 4. create GITHUB secret manually

create some secrets manually first, which I didn't want to put in git.

create OAuth App on Github for Backstage login: https://backstage.io/docs/auth/github/provider/

- Homepage URL: https://portal-metalstack.platform-engineer.cloud/
- Authorization callback URL: https://portal-metalstack.platform-engineer.cloud/

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App for the following environment variables.

```
export METALSTACK_GITHUB_CLIENTID=<value from steps above>
export METALSTACK_GITHUB_CLIENTSECRET=<value from steps above>
kubectl create secret generic -n backstage manual-secret --from-literal=GITHUB_CLIENTSECRET=${METALSTACK_GITHUB_CLIENTSECRET} --from-literal=GITHUB_CLIENTID=${METALSTACK_GITHUB_CLIENTID}
```

Restart backstage pod:
```
kubectl rollout restart deploy/sx-cnp -n backstage
```

### 5. log in to argocd

in your favorite browser:  https://argocd-metalstack.platform-engineer.cloud/

from latest experiences it takes a long time that cert-manager creates the correct certificate and secret.
we need to investigate why this happens.

if argocd says "server.secretkey" is missing, try

```
kubectl rollout restart deploy/argocd-server -n argocd
```

If ingress is not working, use port-forwarding for accessing argocd console and investigate what is wrong
```
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

- Username: `admin`
- Password: `kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

### 6. log in to kargo

in your favorite browser:  https://kargo-metalstack.platform-engineer.cloud/

Password: 'admin'

### 7. log in to backstage

in your favorite browser:  https://portal-metalstack.platform-engineer.cloud

### 8. log in to grafana

in your favorite browser:  https://grafana-metalstack.platform-engineer.cloud

- Username: `admin`
- Password: `prom-operator`





