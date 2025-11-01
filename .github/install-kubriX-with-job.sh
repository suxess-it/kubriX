#!/usr/bin/env bash
set -euo pipefail

# Config (from the manifest)
MANIFEST_URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/refs/heads/${KUBRIX_UPSTREAM_BRANCH:=$KUBRIX_REPO_BRANCH}/install-manifests.yaml"
NAMESPACE="kubrix-install"
JOB_NAME="kubrix-install-job"

echo "Applying manifest..."

curl -H "Authorization: token ${KUBRIX_REPO_PASSWORD}" \
  -H 'Accept: application/vnd.github.v3.raw' \
  -O \
  -L ${MANIFEST_URL}

echo "checking if image got build in this PR and should be used ..."
if [[ -n "${PR_NUMBER:-}" ]]; then
  echo "using kubrix-installer:pr-${PR_NUMBER} image"
  cat install-manifests.yaml \
   | sed 's,image: ghcr.io/suxess-it/kubrix-installer:latest,image: ghcr.io/suxess-it/kubrix-installer:pr-'"${PR_NUMBER}"',g' \
   | kubectl apply -f -
else
  echo "using kubrix-installer:latest image"
  cat install-manifests.yaml | kubectl apply -f -
fi

echo "Ensuring namespace exists..."
kubectl get ns "${NAMESPACE}" >/dev/null

# Helper to get the Job's pod (Jobs label pods with job-name=<jobname>)
get_pod() {
  kubectl get pod -n "${NAMESPACE}" \
    -l "job-name=${JOB_NAME}" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true
}

# Wait for the pod to appear
echo "Waiting for Job pod to be created..."
for _ in {1..60}; do
  POD="$(get_pod)"
  if [[ -n "${POD}" ]]; then
    echo "Found pod: ${POD}"
    break
  fi
  sleep 2
done
if [[ -z "${POD}" ]]; then
  echo "Pod for job ${JOB_NAME} did not appear in time." >&2
  exit 1
fi

# Wait until the pod is Running (or already Succeeded/Failed)
echo "Waiting for pod to be Running (or to finish quickly)..."
for _ in {1..60}; do
  PHASE="$(kubectl get pod "${POD}" -n "${NAMESPACE}" -o jsonpath='{.status.phase}')"
  case "${PHASE}" in
    Running)
      echo "Pod is Running."
      break
      ;;
    Succeeded|Failed)
      echo "Pod phase is ${PHASE}."
      break
      ;;
    *)
      sleep 2
      ;;
  esac
done

# Follow logs until the container exits (handles both Running -> Succeeded and quick-complete Jobs)
echo "---- BEGIN JOB LOGS (${POD}) ----"
# If the pod already finished, logs -f will still stream any remaining buffers and then exit
kubectl logs -n "${NAMESPACE}" -f "pod/${POD}" --all-containers=true || true
echo "---- END JOB LOGS (${POD}) ----"

# Quick settle loop (the Job controller may need a moment to set conditions)
echo "Checking Job conditions..."
for _ in {1..30}; do
  COMPLETED="$(kubectl get job -n "${NAMESPACE}" "${JOB_NAME}" -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' 2>/dev/null || true)"
  FAILED="$(kubectl get job -n "${NAMESPACE}" "${JOB_NAME}" -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}' 2>/dev/null || true)"
  SUCCEEDED_COUNT="$(kubectl get job -n "${NAMESPACE}" "${JOB_NAME}" -o jsonpath='{.status.succeeded}' 2>/dev/null || echo 0)"
  FAILED_COUNT="$(kubectl get job -n "${NAMESPACE}" "${JOB_NAME}" -o jsonpath='{.status.failed}' 2>/dev/null || echo 0)"

  if [[ "${COMPLETED}" == "True" || "${FAILED}" == "True" ]]; then
    break
  fi
  sleep 2
done

echo "Job status: complete=${COMPLETED:-False} failed=${FAILED:-False} succeeded=${SUCCEEDED_COUNT:-0} failedPods=${FAILED_COUNT:-}"
# Check outcome explicitly
COMPLETED="$(kubectl get job "${JOB_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')"
FAILED="$(kubectl get job "${JOB_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}')"
SUCCEEDED_COUNT="$(kubectl get job "${JOB_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.succeeded}')"
FAILED_COUNT="$(kubectl get job "${JOB_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.failed}')"

echo "Job status: complete=${COMPLETED:-False} failed=${FAILED:-False} succeeded=${SUCCEEDED_COUNT:-0} failedPods=${FAILED_COUNT:-0}"

if [[ "${COMPLETED}" == "True" && "${FAILED}" != "True" && "${SUCCEEDED_COUNT:-0}" -ge 1 ]]; then
  echo "✅ Job ${JOB_NAME} finished successfully."
  exit 0
else
  echo "❌ Job ${JOB_NAME} did not complete successfully. See logs above and describe output below."
  echo
  kubectl describe job "${JOB_NAME}" -n "${NAMESPACE}" || true
  echo
  kubectl get pods -n "${NAMESPACE}" -l "job-name=${JOB_NAME}" -o wide || true
  exit 1
fi
