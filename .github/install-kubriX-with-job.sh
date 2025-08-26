#!/usr/bin/env bash
set -euo pipefail

# Config (from the manifest)
MANIFEST_URL="https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/install-manifests.yaml"
NAMESPACE="kubrix-install"
JOB_NAME="kubrix-install-job"

echo "Applying manifest..."
kubectl apply -f "${MANIFEST_URL}"

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
for _ in {1..300}; do
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

# Wait for Job completion (or failure) with a timeout
echo "Waiting for Job to finish..."
set +e
kubectl wait -n "${NAMESPACE}" --for=condition=complete "job/${JOB_NAME}" --timeout=30m
WAIT_RC=$?
set -e

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
