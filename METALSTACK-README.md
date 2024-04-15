# SX-CNP on Metalstack

## how to set it up

### prereqs

if you manage your DNS-Names in AWS Route53 with external-dns:
create IAM policy on AWS for AWS Route53: https://kubernetes-sigs.github.io/external-dns/v0.14.1/tutorials/aws/#iam-policy

then create User and static credentials based on https://kubernetes-sigs.github.io/external-dns/v0.14.1/tutorials/aws/#static-credentials
#TODO: i created the user in console, because I was too confused with logging into with aws cli. I need to understand and document this.

create a file `credentials` where "Access key" and "Secret access key" are stored like this:

```
[default]
aws_access_key_id = <access key>
aws_secret_access_key = <secret access key>
```

### 1. create metalstack cluster

Create a K8s cluster on https://console.metalstack.cloud/, copy the KUBECONFIG to your local machine to `~/.kube/metalstack-config ` and set the KUBECONFIG to this file.

```
export KUBECONFIG=~/.kube/metalstack-config 
```

### 2. create AWS secret for external-dns 
create namespace and secret and delete local credentials file for security reasons:
```
kubectl create ns external-dns
kubectl create secret generic -n external-dns sx-external-dns --from-file credentials
rm credentials
```

### 3. install the platform stack as follows

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

### 4. wait until everything except backstage is app and running

wait until all pods are started:

```
watch kubectl get pods -A
```

wait until all apps are synced and healthy

```
watch kubectl get applications -n argocd
```

backstage is still progressing. 

### 5. Create some secrets manually

This should get fixed in the future because it is obviously not secure (maybe with ESO, some secrets manager, crossplane, ...)

#### argocd

create argocd secret for admin user and mitigate server.secretkey issue to https://github.com/suxess-it/sx-cnp-oss/issues/48

```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/platform-apps/charts/argocd/manual-secret/argocd-secret.yaml
```
Info: I apply a file because the bcrypt value with "kubectl create secret ... --from-literal" gets messed up

#### backstage

create OAuth App on Github for Backstage login: https://backstage.io/docs/auth/github/provider/

- Homepage URL: https://portal-metalstack.platform-engineer.cloud/
- Authorization callback URL: https://portal-metalstack.platform-engineer.cloud/

use GITHUB_CLIENTSECRET and GITHUB_CLIENTID from your Github OAuth App for the following environment variables.

create ArgoCD Token for backstage account:

```
argocd login argocd-metalstack.platform-engineer.cloud --grpc-web
argocd account get --account backstage --grpc-web
argocd account generate-token --account backstage --grpc-web

use output in variable
export ARGOCD_AUTH_TOKEN="argocd.token=<output from above>"
```

create Grafana ServiceAccount token for backstage:

```
ID=$( curl -k -X POST https://grafana-metalstack.platform-engineer.cloud/api/serviceaccounts --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage","role": "Viewer","isDisabled": false}' | jq -r .id )

export GRAFANA_TOKEN=$(curl -k -X POST https://grafana-metalstack.platform-engineer.cloud/api/serviceaccounts/${ID}/tokens --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage"}' | jq -r .key)
```

```
export METALSTACK_GITHUB_CLIENTID=<value from steps above>
export METALSTACK_GITHUB_CLIENTSECRET=<value from steps above>
export GITHUB_ORG=<your github handle>
export GITHUB_TOKEN=<your personal access token>
export K8S_SA_TOKEN=$( kubectl get secret backstage-locator -n backstage  -o jsonpath='{.data.token}' | base64 -d )
kubectl create secret generic -n backstage manual-secret --from-literal=GITHUB_CLIENTSECRET=${METALSTACK_GITHUB_CLIENTSECRET} --from-literal=GITHUB_CLIENTID=${METALSTACK_GITHUB_CLIENTID} --from-literal=GITHUB_ORG=${GITHUB_ORG} --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN} --from-literal=K8S_SA_TOKEN=${K8S_SA_TOKEN} --from-literal=ARGOCD_AUTH_TOKEN=${ARGOCD_AUTH_TOKEN} --from-literal=GRAFANA_TOKEN=${GRAFANA_TOKEN}
```

Restart backstage pod:
```
kubectl rollout restart deploy/sx-backstage -n backstage
```

### 6. log in to the tools

| Tool    | URL | Username | Password |
| -------- | ------- | ------- | ------- |
| Backstage  | https://portal-metalstack.platform-engineer.cloud/  | via github | via github |
| ArgoCD | https://argocd-metalstack.platform-engineer.cloud/ | admin | admin |
| Kargo | https://kargo-metalstack.platform-engineer.cloud/     | admin | - |
| Grafana    | https://grafana-metalstack.platform-engineer.cloud/   | admin | prom-operator |


### 7. Example App deployen

Create a demo-app and kargo pipeline for this demo app:
```
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/team-apps/team-apps-metalstack.yaml -n argocd
```

The demo-app gitops-repo is in `https://github.com/suxess-it/sx-cnp-oss-demo-app`
Via an appset 3 stages get deployed and are managed in a Kargo-Project: `https://kargo-metalstack.platform-engineer.cloud/project/kargo-demo-app`

kargo needs to write to your gitops repo to promote changed from one stage to another. in this demo we use the [suxess-it demo-app](https://github.com/suxess-it/sx-cnp-oss-demo-app).

```
export GITHUB_USERNAME=<your github handle>
export GITHUB_PAT=<your personal access token>
kubectl create secret generic git-demo-app -n kargo-demo-app --from-literal=type=git --from-literal=url=https://github.com/suxess-it/sx-cnp-oss-demo-app --from-literal=username=${GITHUB_USERNAME} --from-literal=password=${GITHUB_PAT}
kubectl label secret git-demo-app -n kargo-demo-app kargo.akuity.io/secret-type=repository
```

URLs for stages (need to be registered in aws route53):

- test: http://test-demo-app-metalstack.platform-engineer.cloud
- qa: http://qa-demo-app-metalstack.platform-engineer.cloud
- prod: http://prod-demo-metalstack.platform-engineer.cloud

### 11. Promote über die Stages

mit kargo



# Troubleshooting

If argocd ingress is not working, use port-forwarding for accessing argocd console and investigate what is wrong
```
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

- Username: `admin`
- Password: `admin`

# AWS helpful things (DRAFT)

install aws cli:
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i ~/bin/aws-cli -b ~/bin
rm -rf aws
rm -rf awscliv2.zip
```
configure aws cli: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html

create IAM policy:
```
aws iam create-policy --policy-name "AllowExternalDNSUpdates" --policy-document file://aws-resources/route53-iam-policy.json
```

