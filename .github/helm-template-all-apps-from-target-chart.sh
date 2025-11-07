#!/usr/bin/env bash
set -euo pipefail

# Config you can tweak
HELM_VALUES_FILE=$1
HELM_SELECTOR=templates/application.yaml
CHART_ROOT=platform-apps/target-chart

emit_stream() {
  # Reads YAML from stdin (note trailing "-")
  yq -r '
    select(.kind == "Application")
    | "NAME " + (.metadata.name // "" | tostring),
      "PATH " + (.spec.source.path // "" | tostring),
      (.spec.source.helm.valueFiles // [] | .[] | "VF " + (.|tostring)),
      "VF_END",
      (.spec.source.helm.parameters // [] | .[] | "P " + (.name|tostring) + "=" + ((.value // "" )|tostring)),
      "P_END"
  ' -
}

process_stream() {
  local appname=""
  local chart=""
  local -a vfiles=()
  local -a params=()

  flush_app() {
    [[ -z "$chart" ]] && return 0

    # Build -f args only for files that actually exist under the chart path
    local -a fargs=()
    for vf in "${vfiles[@]}"; do
      local full="${chart}/${vf}"
      if [[ -f "$full" ]]; then
        fargs+=( -f "$full" )
      fi
    done

    # Build --set-string args (each "name=value" as separate argv items)
    local -a sargs=()
    for kv in "${params[@]}"; do
      sargs+=( --set-string "$kv" )
    done

    # Final command (argv-safe)
    local -a cmd=( helm template "$chart" "${fargs[@]}" "${sargs[@]}" )
    # echo ">>> ${cmd[*]}"

    # Run it (comment out next line if you only want to print)
    "${cmd[@]}"

    # Reset for next app
    appname=""
    chart=""
    vfiles=()
    params=()
  }

  while IFS= read -r line || [[ -n "${line:-}" ]]; do
    local tag="${line%% *}"
    local rest=""
    [[ "$line" == *" "* ]] && rest="${line#* }"

    case "$tag" in
      NAME) appname="$rest" ;;
      PATH) flush_app; chart="$rest" ;;
      VF)   [[ -n "$rest" ]] && vfiles+=( "$rest" ) ;;
      VF_END) : ;;
      P)    [[ -n "$rest" ]] && params+=( "$rest" ) ;;
      P_END) : ;;
      *) : ;;
    esac
  done

  flush_app
}

# Helm render → yq emit → process
helm template "$CHART_ROOT" -f "$CHART_ROOT/$HELM_VALUES_FILE" -s "$HELM_SELECTOR" \
| emit_stream \
| process_stream

