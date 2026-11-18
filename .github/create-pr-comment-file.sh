#!/bin/bash

set -euo pipefail

testCase=$1
valuesFilesList=$2
read -ra setValues <<< "${3:-}"

echo "changes: ${CHANGED_APPS:-}"

declare -A APPS=()

if [[ -z "${CHANGED_APPS:-}" || "${CHANGED_APPS}" == "[]" ]]; then
  # All apps = all direct subdirectories of platform-apps/charts
  while IFS= read -r app; do
    APPS["$app"]=1
  done < <(find pr/platform-apps/charts -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
else
  mapfile -t CHANGED < <(jq -r '.[]' <<<"$CHANGED_APPS")

  for f in "${CHANGED[@]}"; do
    if [[ "$f" =~ ^platform-apps/charts/([^/]+)/ ]]; then
      APPS["${BASH_REMATCH[1]}"]=1
    fi
  done
fi

echo "diff apps: ${!APPS[*]}"

mkdir -p out/pr out/target out-default-values/pr out-default-values/target "comment-files/${testCase}"
IFS=',' read -ra valuesFileNames <<< "${valuesFilesList}"

for env in pr target; do
  pushd "${env}/platform-apps/charts" >/dev/null
  for chart in "${!APPS[@]}"; do
    [[ -d "${chart}" ]] || continue
    echo "${chart}"
    helm dependency update "${chart}"
    # with different aspect specific values we need to render the charts with a specific set of values files, not with every file by itself.
    #   since we already install the charts in the kind github actions with the values "values-kubrix-default.yaml, values-cluster-kind.yaml"
    #   we will use also this set for rendering the chart. In the future this might change, to also test the other aspect specific values.
    valuesFiles=()
    for valuesFile in "${valuesFileNames[@]}"; do
      if [[ -f "${chart}/${valuesFile}" ]]; then
        valuesFiles+=("-f" "${chart}/${valuesFile}")
      fi
    done
    outputDir="../../../out/${env}/${chart}/${testCase}"
    mkdir -p "${outputDir}"
    echo "run command: 'helm template sx-${chart} --include-crds ${chart} ${valuesFiles[*]} ${setValues[*]} --output-dir ${outputDir}'"
    helm template "sx-${chart}" --include-crds "${chart}" "${valuesFiles[@]}" "${setValues[@]}" --output-dir "${outputDir}"
    # get default values of subcharts
    # to compare between different subchart versions we need to write to values files without version names
    while read -r subchart_name subchart_version _; do
      [[ -n "${subchart_name}" ]] || continue
      helm show values "${chart}/charts/${subchart_name}-${subchart_version}.tgz" \
        > "../../../out-default-values/${env}/${chart}_${subchart_name}_default-values.out" || true
    done < <(helm dependency list "${chart}" | tail -n +2)
  done
  popd >/dev/null
done

diff -U 4 -r out-default-values/target out-default-values/pr > out/default-values-diff.txt || true
diff -U 4 -rN out/target out/pr > out/diff.txt || true

# .github/gitops-diff-comments.py turns these into PR comments after all test cases are rendered.
# Only non-empty diffs are kept, so no artifact is uploaded when nothing changed.
for diffFile in out/diff.txt out/default-values-diff.txt; do
  if [[ -s "${diffFile}" ]]; then
    cp "${diffFile}" "comment-files/${testCase}/"
  fi
done
