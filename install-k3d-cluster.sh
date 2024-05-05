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
  -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/bootstrap-argocd-values.yaml \
  --wait

kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/bootstrap-app-k3d.yaml -n argocd


# max wait for 3 minutes
end=$((SECONDS+180))
argocd_apps="argocd sx-kube-prometheus-stack"

all_apps_synced="true"
while [ $SECONDS -lt $end ]; do
  all_apps_synced="true"
  for app in ${argocd_apps} ; do
    kubectl get application -n argocd ${app} | grep "Synced.*Healthy"
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
      all_apps_synced="false"	
    fi
  done
  if [ ${all_apps_synced} = "true" ] ; then
    echo "first apps are synced"
    break
  fi
  kubectl get application -n argocd
  sleep 10
done

# apply argocd-secret to set admin user and password
kubectl apply -f https://raw.githubusercontent.com/suxess-it/sx-cnp-oss/main/platform-apps/charts/argocd/manual-secret/argocd-secret.yaml

argocd login argocd-127-0-0-1.nip.io --grpc-web --insecure --username admin --password admin
export ARGOCD_AUTH_TOKEN="argocd.token=$( argocd account generate-token --account backstage --grpc-web )"

ID=$( curl -k -X POST https://grafana-127-0-0-1.nip.io/api/serviceaccounts --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage","role": "Viewer","isDisabled": false}' | jq -r .id )
export GRAFANA_TOKEN=$(curl -k -X POST https://grafana-127-0-0-1.nip.io/api/serviceaccounts/${ID}/tokens --user 'admin:prom-operator' -H "Content-Type: application/json" -d '{"name": "backstage"}' | jq -r .key)

export K8S_SA_TOKEN=$( kubectl get secret backstage-locator -n backstage  -o jsonpath='{.data.token}' | base64 -d )
kubectl create secret generic -n backstage manual-secret --from-literal=GITHUB_CLIENTSECRET=${GITHUB_CLIENTSECRET} --from-literal=GITHUB_CLIENTID=${GITHUB_CLIENTID} --from-literal=GITHUB_ORG=${GITHUB_ORG} --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN} --from-literal=K8S_SA_TOKEN=${K8S_SA_TOKEN} --from-literal=ARGOCD_AUTH_TOKEN=${ARGOCD_AUTH_TOKEN} --from-literal=GRAFANA_TOKEN=${GRAFANA_TOKEN}
kubectl rollout restart deploy/sx-backstage -n backstage

# max wait for 10 minutes
end=$((SECONDS+600))
argocd_apps="argocd sx-backstage sx-loki sx-kubecost sx-keycloak sx-promtail sx-tempo sx-crossplane sx-bootstrap-app sx-kargo approved-application-team-app sx-cert-manager sx-argo-rollouts sx-external-secrets sx-kyverno sx-kube-prometheus-stack"

all_apps_synced="true"
while [ $SECONDS -lt $end ]; do
  all_apps_synced="true"
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
 echo "not all apps synced and healthy after 6ßß seconds"
 exit 1
fi
