#!/bin/bash

# create image list for the kubriX platform

set -e

# TODO: better check with 'helm plugin list |grep ^images'
helm plugin install https://github.com/nikhilsbhat/helm-images || true

mkdir -p image-list

cd platform-apps/charts

echo "create the images markdown"
echo "# Image list" > ../../image-list/image-list.md
for chart in $( ls -d */ | sed 's#/##' ); do
  echo "${chart}"
  echo "## ${chart}" >> ../../image-list/image-list.md
  helm dependency update ${chart} 1> /dev/null 2>&1
  # with different aspect specific values we need to render the charts with a specific set of values files, not with every file by itself.
  #   since we already install the charts in the kind github actions with the values "values-kubrix-default.yaml, values-cluster-kind.yaml"
  #   we will use also this set for rendering the chart. In the future this might change, to also test the other aspect specific values.
  valuesFiles=( )
  [[ -f ${chart}/values-kubrix-default.yaml ]] && valuesFiles+=( "-f ${chart}/values-kubrix-default.yaml" )
  [[ -f ${chart}/values-cluster-kind.yaml ]] && valuesFiles+=( "-f ${chart}/values-cluster-kind.yaml" )
  helm images get ${chart} ${valuesFiles[@]} --log-level error --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver" | sort -u | sed 's/^/* /' >> ../../image-list/image-list.md
done

echo "create the images json"
echo -n "" > ../../image-list/image-list-temp.json
for chart in $( ls -d */ | sed 's#/##' ); do
  echo "${chart}"
  helm dependency update ${chart} 1> /dev/null 2>&1
  for image in $(
    # with different aspect specific values we need to render the charts with a specific set of values files, not with every file by itself.
    #   since we already install the charts in the kind github actions with the values "values-kubrix-default.yaml, values-cluster-kind.yaml"
    #   we will use also this set for rendering the chart. In the future this might change, to also test the other aspect specific values.
    valuesFiles=( )
    [[ -f ${chart}/values-kubrix-default.yaml ]] && valuesFiles+=( "-f ${chart}/values-kubrix-default.yaml" )
    [[ -f ${chart}/values-cluster-kind.yaml ]] && valuesFiles+=( "-f ${chart}/values-cluster-kind.yaml" )
    helm images get ${chart} ${valuesFiles[@]} --log-level error --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver" \
    | sort -u ); do
    id=$( echo -n "${chart}_$( echo ${image} | awk -F/ '{print $NF}' | sed 's/:/_/g' )" )
    echo "{\"chart\": \"${chart}\", \"image\": \"${image}\", \"id\": \"${id}\"}" >> ../../image-list/image-list-temp.json
  done
done
jq --slurp '.' ../../image-list/image-list-temp.json > ../../image-list/image-list.json
rm ../../image-list/image-list-temp.json
