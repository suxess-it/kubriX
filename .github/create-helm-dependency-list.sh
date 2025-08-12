#!/usr/bin/env bash

release_filter=$1
multilevel=$2

# global array with chart identifiers, i.e., chart_name-chart_version-repo_url strings
charts=()

function chart_deps() {
  [ ${#charts[@]} -eq 0 ] && return

  local chart_identifier="${charts[0]}"
  local chart_name chart_version repo_url
  local status
  local deps

  # get chart name and version
  IFS=- read chart_name chart_version repo_url <<< "$chart_identifier"
  
  printf 'Processing %s from %s ...\n' $chart_name $repo_url

  # pull chart via URL
  if [[ $repo_url =~ 'oci://' ]]; then
    helm pull $repo_url --version $chart_version --untar >/dev/null 2>&1
  else
    helm pull $chart_name --repo $repo_url --version $chart_version --untar >/dev/null 2>&1
  fi
  
  if [ $? -ne 0 ]; then
    printf 'Unable to pull %s from %s.\n\n' $chart_name $repo_url
    return
  fi

  deps="$(helm dependency list ./$chart_name)"

  printf '%s deps:\n%s\n\n' "$chart_name-$chart_version" "$deps"

  if [ -n "$deps" ] && [ -n "$multilevel" ]; then
    charts+=($(echo "$deps" | awk 'NR > 1 { print $1"-"$2"-"$3; }'))
  fi

  rm -rf $chart_name
  rm -rf $chart_name-$chart_version.tgz
}

# get all helm dependencies from local chart
helm dependency update

# extract all dependecies
helm dependency list .

# get partial chart identifier from the YAML information about the single matching release
chart_identifier="$(helm list --filter $release_filter --all-namespaces --output=yaml
  | awk '/chart:/ { print $2; }')"

# extract chart name and version
IFS=- read chart_name chart_version <<< "$chart_identifier"

# get chart repository URL from repo or hub
chart_path="$(helm search repo $chart_name --version $chart_version --output yaml
  | grep 'version: '$chart_version -B 1
  | awk '/name:/ { print $2; }')"
if [ -n "$chart_path" ]; then
  IFS=/ read repo_name chart_name <<< "$chart_path"
  repo_url="$(helm repo list | awk '/'$repo_name'/ { print $2; }')"
else
  repo_url="$(helm search hub $chart_name --output yaml
    | grep 'version: '$chart_version -B 2
    | awk 'NR == 1 && /url:/ { print $2; }')"
fi
if [ -z "$repo_url" ]; then
  >&2 printf 'Repository not found for release chart %s version %s.' $chart_name $chart_version
  exit 1
fi

# first chart identifier comes
chart_identifier=$chart_identifier-$repo_url
charts+=("$chart_identifier")

while [ ${#charts[@]} -ne 0 ]; do
  chart_deps 
  charts=("${charts[@]:1}")
done