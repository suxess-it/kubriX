#!/bin/bash

set -e

testCase=$1
valuesFilesList=$2
setValues=$3

curl -sL https://github.com/zegl/kube-score/releases/download/v1.20.0/kube-score_1.20.0_linux_amd64.tar.gz | tar zx kube-score
chmod u+x kube-score

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
    ../../kube-score score - || true
done