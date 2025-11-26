#!/bin/bash

set -e

testCase=$1
valuesFilesList=$2
setValues=$3

curl -sL https://github.com/yannh/kubeconform/releases/download/v0.7.0/kubeconform-linux-amd64.tar.gz | tar zx kubeconform
chmod u+x kubeconform

cd platform-apps/charts
for chart in $( ls -d */ | sed 's#/##' ); do
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
  helm template  --include-crds ${chart} ${valuesFiles[@]} ${setValues} | \
    ../../kubeconform -output pretty \
    -schema-location default \
    -schema-location "https://raw.githubusercontent.com/suxess-it/kubriX/${GITHUB_HEAD_REF}/kubeconform-schemas/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
    -schema-location "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json" \
    -strict -kubernetes-version 1.31.0 - || true
done