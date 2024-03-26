# how to install the sx-cnp-oss stack on metalstack

after creating a K8s cluster on https://console.metalstack.cloud/ and copying the KUBECONFIG to your local machine you need to do the following:

```
# point the KUBECONFIG variable to the kubeconfig file you exported (unless it is in the default location ~/.kube/config)
export KUBECONFIG=~/.kube/metalstack-config 

# install argocd one time (and then let it manage itself via argocd)
kubectl create namespace argocd

helm install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version 6.4.0 \
  --namespace argocd \
  --create-namespace \
  --set additionalLabels."app\.kubernetes\.io/instance"=argocd \
  --wait

# install a bootstrap app which then installs the whole stack automagically

kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/bootstrap-app-metalstack.yaml -n argocd

# if anything stucks or ingress is not working, use port-forwarding for accessing argocd console
kubectl port-forward svc/argocd-server -n argocd 8080:80


Backstage: portal-metalstack.platform-engineer.cloud
ArgoCD: argocd-metalstack.platform-engineer.cloud
Kargo: kargo-metalstack.platform-engineer.cloud
Grafana: grafana-metalstack.platform-engineer.cloud

