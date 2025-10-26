#!/bin/bash

# create a trivy scan report for all images in the kubrix repo

set -e

# install trivy
curl -L https://github.com/aquasecurity/trivy/releases/download/v0.61.0/trivy_0.61.0_Linux-32bit.tar.gz -o trivy.tar.gz
tar -xzvf trivy.tar.gz trivy
chmod u+x trivy

# install helm images plugin
helm plugin install https://github.com/nikhilsbhat/helm-images || true

mkdir -p trivy-scan-reports

cd platform-apps/charts
for chart in $( ls -d */ | sed 's#/##' ); do
  mkdir -p ../../trivy-scan-reports/${chart}
  echo "get images for chart: ${chart}"
  helm dependency update ${chart}
  # with different aspect specific values we need to render the charts with a specific set of values files, not with every file by itself.
  #   since we already install the charts in the kind github actions with the values "values-kubrix-default.yaml, values-cluster-kind.yaml"
  #   we will use also this set for rendering the chart. In the future this might change, to also test the other aspect specific values.
  valuesFiles=( )
  [[ -f ${chart}/values-kubrix-default.yaml ]] && valuesFiles+=( "-f ${chart}/values-kubrix-default.yaml" )
  [[ -f ${chart}/values-cluster-kind.yaml ]] && valuesFiles+=( "-f ${chart}/values-cluster-kind.yaml" )
  # this is just for the target where the 'kind' values have their old name. this gets fixed after this commit is in main branch
  [[ -f ${chart}/values-kind.yaml ]] && valuesFiles+=( "-f ${chart}/values-kind.yaml" )
  helm images get ${chart} ${valuesFiles[@]} --log-level error --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver" | sort -u > ../../trivy-scan-reports/${chart}/images.txt
  > ../../trivy-scan-reports/${chart}_scan_summary_report.md
  for image in $(cat ../../trivy-scan-reports/${chart}/images.txt) ; do
    output_file=$( echo -n "${chart}_$( echo ${image} | awk -F/ '{print $NF}' )" )
    ../../trivy image --scanners vuln --severity HIGH,CRITICAL -f template --template "@../../.github/trivy-scan-markdown.tpl" -o ../../trivy-scan-reports/${chart}/${output_file}.md ${image}
    cat ../../trivy-scan-reports/${chart}/${output_file}.md >> ../../trivy-scan-reports/${chart}_scan_summary_report.md
  done
  rm -rf ../../trivy-scan-reports/${chart}
done
cd -
rm trivy trivy.tar.gz
