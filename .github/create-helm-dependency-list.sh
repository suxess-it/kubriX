#!/usr/bin/env bash
set -euo pipefail

helm plugin install https://github.com/origranot/helm-cascade || true

mkdir -p helm-chart-list

cd platform-apps/charts
echo -n "" > ../../helm-chart-list/helm-chart-list.txt

for chart in $( ls -d */ | sed 's#/##' ); do
  echo "Chart: ${chart}"
  helm dependency update ${chart} 

  # helm archives need to get extraced for "helm cascade list"
  for archive in $( find ${chart}/charts -maxdepth 1 -type f -name '*.tgz' ) ; do
    tar -xzf ${archive} -C ${chart}/charts/
  done

  helm cascade list ${chart} | tee -a ../../helm-chart-list/helm-chart-list.txt
done

echo "delete extraced files again ..."
for chart in $( ls -d */ | sed 's#/##' ); do
  echo "Chart: ${chart}"
  for archive in $( find ${chart}/charts -maxdepth 1 -type f -name '*.tgz' ) ; do
    echo "processing archive ${archive}"
    dir="$(tar -tzf "$archive" | sed -n '1p' | cut -d/ -f1)"
    echo "delete ${chart}/charts/$dir again"
    rm -rf "${chart}/charts/$dir"
  done
done

