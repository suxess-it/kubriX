#!/bin/bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Get changed charts between the target and current trees. Comparing each chart
# separately also handles charts that exist on only one side.
changed_charts="$(
  for chart_dir in pr/platform-apps/charts/* target/platform-apps/charts/*; do
    [[ -d "${chart_dir}" ]] || continue
    basename -- "${chart_dir}"
  done \
    | sort -u \
    | while IFS= read -r chart; do
        [[ "${chart}" == "image-list" ]] && continue
        if ! diff -qr \
          "pr/platform-apps/charts/${chart}" \
          "target/platform-apps/charts/${chart}" >/dev/null 2>&1; then
          printf '%s\n' "${chart}"
        fi
      done
)"

if [[ -z "${changed_charts}" ]]; then
  echo "no changes"
  echo "CHANGES=false" >> "${GITHUB_ENV}"
  echo "CRITICAL_FIXED=false" >> "${GITHUB_ENV}"
  echo "HIGH_FIXED=false" >> "${GITHUB_ENV}"
  echo "CRITICAL_INTRODUCED=false" >> "${GITHUB_ENV}"
  echo "HIGH_INTRODUCED=false" >> "${GITHUB_ENV}"
  exit 0
else
  echo "CHANGES=true" >> "${GITHUB_ENV}"
fi

# install tools only when chart changes need inspection
helm plugin install https://github.com/nikhilsbhat/helm-images --version v0.1.8 --verify=false

echo "charts which differ between main and PR:"
echo "${changed_charts}"

# get images for these charts to see if also the images changed
mkdir -p out/pr
mkdir -p out/target

for env in pr target; do
  cd "${env}/platform-apps/charts"

  for chart in ${changed_charts}; do
    echo "get images for chart: ${chart}"

    if [[ ! -d "${chart}" ]]; then
      echo "chart '${chart}' does not exist in ${env}"
      : > "../../../out/${env}/${chart}-images.txt"
      continue
    fi

    helm dependency update "${chart}"

    valuesFiles=()

    [[ -f "${chart}/values-kubrix-default.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kubrix-default.yaml")
    [[ -f "${chart}/values-kubrix-default-prime.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kubrix-default-prime.yaml")
    [[ -f "${chart}/values-cluster-kind.yaml" ]] && valuesFiles+=("-f" "${chart}/values-cluster-kind.yaml")
    [[ -f "${chart}/values-cluster-kind-prime.yaml" ]] && valuesFiles+=("-f" "${chart}/values-cluster-kind-prime.yaml")
    [[ -f "${chart}/values-kind.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kind.yaml")
    [[ -f "${chart}/values-kind-prime.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kind-prime.yaml")

    helm images get "${chart}" "${valuesFiles[@]}" \
      --log-level error \
      --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver,Provider,Configuration,Function" \
      | sort -u > "../../../out/${env}/${chart}-images.txt"
  done

  cd - >/dev/null
done

changed_images_charts="$(
  {
    diff -q out/target out/pr || true
  } \
    | awk '{print $2}' \
    | awk -F/ '{print $3}' \
    | sed 's/-images.txt//g' \
    | sed '/^$/d' \
    | sort -u
)"

echo "charts where images changed between PR and main:"
echo "${changed_images_charts}"

# scan every image of the changed charts; trivy-scan-diff.py reads the image name
# from each JSON report, so file names only need to be unique
mkdir -p out/pr/scans out/target/scans
for chart in ${changed_images_charts}; do
  for env in pr target; do
    mkdir -p "out/${env}/scans/${chart}"
    report_number=0
    while IFS= read -r image; do
      [[ -z "${image}" ]] && continue

      echo "scanning image '${image}' for chart '${chart}'"

      report_number=$((report_number + 1))
      trivy image \
        --scanners vuln \
        -f json \
        -o "out/${env}/scans/${chart}/${report_number}.json" \
        "${image}"
    done < "out/${env}/${chart}-images.txt"
  done
done

python3 "${script_dir}/trivy-scan-diff.py" \
  --target-dir out/target/scans \
  --pr-dir out/pr/scans \
  --github-env "${GITHUB_ENV}" \
  --comment-file out/comment-diff-trivy-scan-result.txt
