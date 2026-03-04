#!/bin/bash

set -e

testCase=$1
valuesFilesList=$2
setValues=$3

echo "changes: $CHANGED_APPS"

declare -A APPS=()

if [[ -z "${CHANGED_APPS:-}" || "${CHANGED_APPS}" == "[]" ]]; then
  # All apps = all direct subdirectories of platform-apps/charts
  while IFS= read -r app; do
    APPS["$app"]=1
  done < <(find platform-apps/charts -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

else
  mapfile -t CHANGED < <(jq -r '.[]' <<<"$CHANGED_APPS")

  for f in "${CHANGED[@]}"; do
    if [[ "$f" =~ ^platform-apps/charts/([^/]+)/ ]]; then
      APPS["${BASH_REMATCH[1]}"]=1
    fi
  done
fi

echo "analyze apps: ${!APPS[@]}"

curl -sL https://github.com/yannh/kubeconform/releases/download/v0.7.0/kubeconform-linux-amd64.tar.gz | tar zx kubeconform
chmod u+x kubeconform

cd platform-apps/charts
for chart in ${!APPS[@]}; do
  echo ${chart}
  helm dependency update ${chart}
  # with different aspect specific values we need to render the charts with a specific set of values files, not with every file by itself.
  #   since we already install the charts in the kind github actions with the values "values-kubrix-default.yaml, values-cluster-kind.yaml"
  #   we will use also this set for rendering the chart. In the future this might change, to also test the other aspect specific values.
  valuesFiles=( )
  IFS=',' read -ra files <<< "${valuesFilesList}"
  for valuesFile in "${files[@]}"; do
      [[ -f ${chart}/${valuesFile} ]] && valuesFiles+=( "-f ${chart}/${valuesFile}" )
      echo "$item"
  done
  echo "'helm template  --include-crds ${chart} "${valuesFiles[@]}" ${setValues} --output-dir ../../../out/${env}/${chart}/${testCase}'"


  # temporary exceptions if upstream projects have problems with conform APIs
  EXTRA_OPTS=""
  # exception due to https://github.com/kubernetes-sigs/gateway-api/issues/4402
  if [[ "${chart}" == "traefik" ]] ; then
    EXTRA_OPTS="-skip CustomResourceDefinition"
  fi


  helm template  --include-crds ${chart} ${valuesFiles[@]} ${setValues} | \
    ../../kubeconform -output pretty \
    ${EXTRA_OPTS} \
    -schema-location default \
    -schema-location "https://raw.githubusercontent.com/suxess-it/kubriX/main/kubeconform-schemas/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
    -schema-location "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json" \
    -strict -kubernetes-version 1.31.0 -
done
