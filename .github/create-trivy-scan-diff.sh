#!/bin/bash
set -euo pipefail

# install trivy
curl -L https://github.com/aquasecurity/trivy/releases/download/v0.69.2/trivy_0.69.2_Linux-64bit.tar.gz -o trivy.tar.gz
tar -xzvf trivy.tar.gz trivy
chmod u+x trivy

# install helm images plugin
helm plugin install https://github.com/nikhilsbhat/helm-images || true

# get changed charts between main and PR
changed_charts="$(
  {
    diff -qr pr/platform-apps/charts target/platform-apps/charts || true
  } \
    | grep -v "platform-apps/charts/image-list" || true
)"

changed_charts="$(
  printf '%s\n' "${changed_charts}" \
    | awk -F/ '{print $4}' \
    | awk -F: '{print $1}' \
    | sed '/^$/d' \
    | sort -u
)"

if [[ -z "${changed_charts}" ]]; then
  echo "no changes"
  echo "CHANGES=false" >> "${GITHUB_ENV}"
  echo "CRITICAL_FIXED=false" >> "${GITHUB_ENV}"
  exit 0
else
  echo "CHANGES=true" >> "${GITHUB_ENV}"
fi

echo "charts which differ between main and PR:"
echo "${changed_charts}"

# get images for these charts to see if also the images changed
mkdir -p out/pr
mkdir -p out/target

for env in pr target; do
  cd "${env}/platform-apps/charts"

  for chart in ${changed_charts}; do
    echo "get images for chart: ${chart}"

    helm dependency update "${chart}"

    valuesFiles=()

    [[ -f "${chart}/values-kubrix-default.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kubrix-default.yaml")
    [[ -f "${chart}/values-cluster-kind.yaml" ]] && valuesFiles+=("-f" "${chart}/values-cluster-kind.yaml")
    [[ -f "${chart}/values-kind.yaml" ]] && valuesFiles+=("-f" "${chart}/values-kind.yaml")

    helm images get "${chart}" "${valuesFiles[@]}" \
      --log-level error \
      --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver" \
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

python3 - <<'PY'
import os
import re
from pathlib import Path

diff_path = Path("out/scan-diff.txt")
diff = diff_path.read_text(encoding="utf-8") if diff_path.exists() else ""

lines = diff.splitlines()
removed_rows = []
current = None

for raw in lines:
    line = raw.strip()
    if not line.startswith("-") or line.startswith("---"):
        continue

    content = re.sub(r"^-+\s*", "", line)

    if "<tr>" in content:
        current = [content]
        continue

    if current is not None:
        current.append(content)
        if "</tr>" in content:
            removed_rows.append("\n".join(current))
            current = None

fixed_critical_rows = [
    row for row in removed_rows
    if re.search(r"\bCVE-\d{4}-\d+\b", row, re.I)
    and re.search(r"\bCRITICAL\b", row, re.I)
]

with open(os.environ["GITHUB_ENV"], "a", encoding="utf-8") as f:
    f.write(f"CRITICAL_FIXED={'true' if fixed_critical_rows else 'false'}\n")

print(f"Detected removed CRITICAL CVE rows: {len(fixed_critical_rows)}")
PY
