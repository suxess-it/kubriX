#!/bin/bash
set -e  # Exit on non-zero exit code from commands

echo "$(date): Running post-start.sh" >> ~/.status.log

# this runs in background each time the container starts

# Ensure kubeconfig is set up. 
k3d kubeconfig merge dev --kubeconfig-merge-default

kubectl apply -k argocd 2>&1 | tee -a ~/.status.log

kubectl wait deployment -n argocd --all --for=condition=Available=True --timeout=90s 2>&1 | tee -a ~/.status.log
ARGOCD_ADMIN_PASSWORD="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo "${ARGOCD_ADMIN_PASSWORD}" > ~/argo-cd-admin-password.txt

kubectl apply -f apps.yaml 2>&1 | tee -a ~/.status.log

argocd login \
  "localhost:31443" \
  --username admin \
  --password ${ARGOCD_ADMIN_PASSWORD} \
  --grpc-web \
  --insecure 2>&1 | tee -a ~/.status.log

echo "Argo CD admin password: ${ARGOCD_ADMIN_PASSWORD}"

echo "$(date): Finished post-start.sh" >> ~/.status.log