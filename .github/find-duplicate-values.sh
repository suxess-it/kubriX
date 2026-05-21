#!/bin/bash

set -euo pipefail

testCase="${1:-}"
valuesFilesList="${2:-}"
# Accepted for the same call shape as kube-score.sh/create-pr-comment-file.sh.
# This scanner compares values files only; --set values are intentionally ignored.
setValues="${3:-}"
outputFile="${4:-}"

if [[ -z "${testCase}" || -z "${valuesFilesList}" ]]; then
  echo "usage: $0 <testCase> <comma-separated-values-files> [setValues] [outputFile]" >&2
  exit 1
fi

ROOT_DIR="${ROOT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CHARTS_DIR="${ROOT_DIR}/platform-apps/charts"
INCLUDE_NULL_DUPLICATES="${INCLUDE_NULL_DUPLICATES:-false}"
TMP_DIR="$(mktemp -d)"
DUPLICATES_FILE="${TMP_DIR}/duplicates.tsv"
: > "${DUPLICATES_FILE}"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

ensure_yq() {
  if command -v yq >/dev/null 2>&1; then
    command -v yq
    return
  fi

  local yq_bin="${RUNNER_TEMP:-/tmp}/kubrix-yq"
  if [[ ! -x "${yq_bin}" ]]; then
    echo "yq not found, downloading local copy..." >&2
    curl -sSL -o "${yq_bin}" \
      "https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64"
    chmod +x "${yq_bin}"
  fi
  echo "${yq_bin}"
}

YQ_BIN="$(ensure_yq)"

merge_json_files() {
  local left="$1"
  local right="$2"
  local output="$3"

  jq -s '
    def deepmerge($left; $right):
      if ($left | type) == "object" and ($right | type) == "object" then
        reduce ($right | keys_unsorted[]) as $key (
          $left;
          .[$key] = if has($key) then
            deepmerge(.[$key]; $right[$key])
          else
            $right[$key]
          end
        )
      else
        $right
      end;
    deepmerge(.[0]; .[1])
  ' "${left}" "${right}" > "${output}"
}

scan_chart() {
  local chart="$1"
  local chart_dir="${CHARTS_DIR}/${chart}"
  local acc_file="${TMP_DIR}/acc-${chart}.json"
  local next_acc_file="${TMP_DIR}/acc-${chart}.next.json"
  local data_file="${TMP_DIR}/data-${chart}.json"
  local valuesFiles=( "values.yaml" )
  local valuesFile

  IFS=',' read -ra matrixFiles <<< "${valuesFilesList}"
  for valuesFile in "${matrixFiles[@]}"; do
    valuesFile="$(xargs <<< "${valuesFile}")"
    [[ -n "${valuesFile}" ]] && valuesFiles+=( "${valuesFile}" )
  done

  echo '{}' > "${acc_file}"

  for valuesFile in "${valuesFiles[@]}"; do
    [[ -f "${chart_dir}/${valuesFile}" ]] || continue

    "${YQ_BIN}" -o=json eval '.' "${chart_dir}/${valuesFile}" > "${data_file}"
    if [[ ! -s "${data_file}" ]] || jq -e '. == null' "${data_file}" >/dev/null; then
      continue
    fi

    while IFS=$'\t' read -r dotPath valueJson; do
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "${chart}" "${valuesFile}" "${dotPath}" "${valueJson}" "${testCase}" \
        >> "${DUPLICATES_FILE}"
    done < <(
      jq -r --slurpfile acc "${acc_file}" '
        def path_to_string:
          map(
            if test("^[A-Za-z_][A-Za-z0-9_-]*$") then
              .
            else
              "[" + tojson + "]"
            end
          ) | join(".");
        def walk_values($path):
          if type == "object" then
            if length == 0 then
              [$path, .]
            else
              to_entries[] | . as $entry | $entry.value | walk_values($path + [$entry.key])
            end
          else
            [$path, .]
          end;
        walk_values([])
        | . as $row
        | select($ENV.INCLUDE_NULL_DUPLICATES == "true" or $row[1] != null)
        | select(try (($acc[0] | getpath($row[0])) == $row[1]) catch false)
        | [($row[0] | path_to_string), ($row[1] | tojson)]
        | @tsv
      ' "${data_file}"
    )

    merge_json_files "${acc_file}" "${data_file}" "${next_acc_file}"
    mv "${next_acc_file}" "${acc_file}"
  done
}

write_markdown_report() {
  local output="$1"

  {
    echo "## Duplicate Helm Values (${testCase})"
    echo
    echo "Values chain: \`values.yaml,${valuesFilesList}\`"
    if [[ -n "${setValues}" ]]; then
      echo
      echo "Note: \`setValues\` was accepted for workflow compatibility but is not checked for file-level duplicates."
    fi
    echo

    if [[ ! -s "${DUPLICATES_FILE}" ]]; then
      echo "No duplicate value definitions found for this values chain."
      return
    fi

    echo "These definitions repeat the same effective value that was already set by an earlier values file in this Helm overlay chain."
    echo
    echo "| App | File | Definition | Value |"
    echo "|---|---|---|---|"

    awk -F '\t' '
      function escape_md(value) {
        gsub(/\|/, "\\\\|", value)
        return value
      }
      function truncate(value) {
        if (length(value) > 140) {
          return substr(value, 1, 137) "..."
        }
        return value
      }
      {
        key = $1 "\t" $2 "\t" $3 "\t" $4
        if (seen[key]++) {
          next
        }
        printf "| `%s` | `%s` | `%s` | `%s` |\n", \
          escape_md($1), escape_md($2), escape_md($3), escape_md(truncate($4))
      }
    ' "${DUPLICATES_FILE}"
  } > "${output}"
}

main() {
  if [[ ! -d "${CHARTS_DIR}" ]]; then
    echo "Could not find ${CHARTS_DIR}" >&2
    exit 1
  fi

  local chartDir chart
  while IFS= read -r chartDir; do
    chart="$(basename "${chartDir}")"
    scan_chart "${chart}"
  done < <(find "${CHARTS_DIR}" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ -z "${outputFile}" ]]; then
    mkdir -p "${ROOT_DIR}/comment-files"
    outputFile="${ROOT_DIR}/comment-files/comment-duplicate-values-${testCase}.md"
  fi

  write_markdown_report "${outputFile}"
  echo "Duplicate values report written to ${outputFile}"
}

main
