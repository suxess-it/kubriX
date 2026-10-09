#!/usr/bin/env bash
# Render the same target values layers as the bootstrap Application.
set -euo pipefail

target=${1:?Usage: render-target-applications.sh TARGET}
chart_root=platform-apps/target-chart
bootstrap_app="bootstrap-app-${target}.yaml"
value_args=()
value_files=$(yq -r '.spec.source.helm.valueFiles[]' "$bootstrap_app")
while IFS= read -r value_file; do
  if [[ -f "$chart_root/$value_file" ]]; then
    value_args+=( -f "$chart_root/$value_file" )
  elif [[ $(yq -r '.spec.source.helm.ignoreMissingValueFiles // false' "$bootstrap_app") != true ]]; then
    echo "Missing target values file: $chart_root/$value_file" >&2
    exit 1
  fi
done <<< "$value_files"
helm template "$chart_root" "${value_args[@]}"
