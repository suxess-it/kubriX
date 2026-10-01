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
curl -L https://github.com/aquasecurity/trivy/releases/download/v0.69.2/trivy_0.69.2_Linux-64bit.tar.gz -o trivy.tar.gz
tar -xzvf trivy.tar.gz trivy
chmod u+x trivy
helm plugin install https://github.com/nikhilsbhat/helm-images || true

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

if [[ -z "${changed_images_charts}" ]]; then
  echo "no image changes"
  echo "CRITICAL_FIXED=false" >> "${GITHUB_ENV}"
  echo "HIGH_FIXED=false" >> "${GITHUB_ENV}"
  echo "CRITICAL_INTRODUCED=false" >> "${GITHUB_ENV}"
  echo "HIGH_INTRODUCED=false" >> "${GITHUB_ENV}"

  diff -U 4 -r out/target/scans out/pr/scans > out/scan-diff.txt || true
  sed 's/DESCRIPTION_HERE/Changes Trivy Scan/g' pr/.github/pr-diff-template.txt > out/comment-diff-trivy-scan.txt
  sed -e "/DIFF_HERE/{r out/scan-diff.txt" -e "d}" out/comment-diff-trivy-scan.txt > out/comment-diff-trivy-scan-result.txt
  exit 0
fi

# create trivy scan reports per image to see if the scan reports changed
for chart in ${changed_images_charts}; do
  mkdir -p "out/pr/scans/${chart}"
  mkdir -p "out/target/scans/${chart}"

  for env in pr target; do
    while IFS= read -r image; do
      [[ -z "${image}" ]] && continue

      echo "scanning image '${image}' for chart '${chart}'"

      output_file="${chart}_$(echo "${image}" | awk -F/ '{print $NF}')"

      ./trivy image \
        --scanners vuln \
        -f template \
        --template "@pr/.github/trivy-scan-markdown.tpl" \
        -o "out/${env}/scans/${chart}/${output_file}.md" \
        "${image}"

      cat "out/${env}/scans/${chart}/${output_file}.md" >> "out/${env}/scans/${chart}/scan_summary.md"
      rm "out/${env}/scans/${chart}/${output_file}.md"
    done < "out/${env}/${chart}-images.txt"
  done
done

diff -U 4 -r out/target/scans out/pr/scans > out/scan-diff.txt || true

sed 's/DESCRIPTION_HERE/Changes Trivy Scan/g' pr/.github/pr-diff-template.txt > out/comment-diff-trivy-scan.txt
sed -e "/DIFF_HERE/{r out/scan-diff.txt" -e "d}" out/comment-diff-trivy-scan.txt > out/comment-diff-trivy-scan-result.txt

python3 "${script_dir}/trivy-scan-diff.py" \
  --target-dir out/target/scans \
  --pr-dir out/pr/scans \
  --github-env "${GITHUB_ENV}"
