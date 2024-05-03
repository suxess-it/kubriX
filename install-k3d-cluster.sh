#!/bin/bash

set -x

# do we need to set this always? I had DNS issues on the train
export K3D_FIX_DNS=1

# in github workflows we use the same script but don't want the k3d cluster to get installed
if [ "${INSTALL_K3D_CLUSTER}" != "false" ] ; then
  k3d cluster create cnp-local-demo \
    -p "80:80@loadbalancer" \
    -p "443:443@loadbalancer" \
    --agents 2 \
    --wait
fi

# create mkcert certs in alle namespaces with ingress
for namespace in backstage kargo monitoring argocd keycloak kubecost; do
  kubectl create namespace ${namespace}
  # for grafana the namespace is not the same as the ingress hostname
  if [ "${namespace}" = "monitoring" ]; then
    mkcert -cert-file ${namespace}-cert.pem -key-file ${namespace}-key.pem grafana-127-0-0-1.nip.io
  else
    mkcert -cert-file ${namespace}-cert.pem -key-file ${namespace}-key.pem ${namespace}-127-0-0-1.nip.io
  fi
  # kargo needs a special secret name according to its helm chart
  if [ "${namespace}" = "kargo" ]; then
    kubectl create secret tls kargo-api-ingress-cert -n ${namespace} --cert=${namespace}-cert.pem --key=${namespace}-key.pem
  else
    kubectl create secret tls ${namespace}-server-tls -n ${namespace} --cert=${namespace}-cert.pem --key=${namespace}-key.pem
  fi
  rm ${namespace}-cert.pem ${namespace}-key.pem
done




# create argocd with helm chart not with install.yaml
# because afterwards argocd is also managed by itself with the helm-chart

helm install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version 6.4.0 \
  --namespace argocd \
  --create-namespace \
  --set additionalLabels."app\.kubernetes\.io/instance"=argocd \
  --wait

kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/bootstrap-app-k3d.yaml -n argocd



# max wait for 10 minutes
end=$((SECONDS+600))
argocd_apps="argocd sx-loki sx-kubecost sx-keycloak sx-promtail sx-tempo sx-crossplane sx-bootstrap-app sx-kargo approved-application-team-app sx-cert-manager sx-argo-rollouts sx-external-secrets sx-kyverno sx-kube-prometheus-stack"

all_apps_synced="true"
while [ $SECONDS -lt $end ]; do
  for app in ${argocd_apps} ; do
    kubectl get application -n argocd ${app} | grep "Synced.*Healthy"
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
      all_apps_synced="false"	
    fi
  done
  if [ ${all_apps_synced} = "true" ] ; then
    echo "all apps are synced! you are ready to take off!"
    break
  fi
  kubectl get application -n argocd
  sleep 10
done
echo "status of all pods"
kubectl get pods -A
if [ ${all_apps_synced} != "true" ] ; then
 echo "not all apps synced and healthy after 1200 seconds"
 exit 1
fi

echo "app 'sx-backstage' is not checked because there we need to manually apply secrets"
