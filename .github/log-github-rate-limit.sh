#!/usr/bin/env bash
# Read-only diagnostics. The budget is shared by all tokens of this installation.
set -euo pipefail

phase="${1:-unspecified}"
if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "GitHub API budget [$phase]: token unavailable; skipping."
  exit 0
fi

response_file=$(mktemp)
trap 'rm -f "$response_file"' EXIT
if ! status=$(curl --silent --show-error --connect-timeout 5 --max-time 20 \
  --output "$response_file" --write-out '%{http_code}' \
  --header 'Accept: application/vnd.github+json' \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  https://api.github.com/rate_limit); then
  echo "GitHub API budget [$phase]: request failed; continuing without diagnostics."
  exit 0
fi
if [[ "$status" != 200 ]]; then
  echo "GitHub API budget [$phase]: HTTP $status; continuing without diagnostics."
  exit 0
fi

if ! budget=$(jq -er '.resources.core |
  select((.limit | type) == "number" and (.used | type) == "number" and
         (.remaining | type) == "number" and (.reset | type) == "number") |
  [.limit, .used, .remaining, (.reset | todateiso8601)] | @tsv' "$response_file"); then
  echo "GitHub API budget [$phase]: invalid response; continuing without diagnostics."
  exit 0
fi
IFS=$'\t' read -r budget_limit budget_used budget_remaining budget_reset <<< "$budget"
sample_time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
echo "GitHub API budget [$phase] sampled=$sample_time resource=core limit=$budget_limit used=$budget_used remaining=$budget_remaining reset=$budget_reset"
echo 'Shared installation budget: concurrent jobs and integrations contribute to these values.'

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    printf '\n### GitHub API budget: %s\n\n' "$phase"
    printf '| Sample (UTC) | Resource | Limit | Used | Remaining | Reset (UTC) |\n'
    printf '|---|---|---:|---:|---:|---|\n'
    printf '| %s | core | %s | %s | %s | %s |\n' "$sample_time" "$budget_limit" "$budget_used" "$budget_remaining" "$budget_reset"
    printf '\nShared installation budget; differences include concurrent jobs and integrations and are not a per-job request count.\n'
  } >> "$GITHUB_STEP_SUMMARY"
fi
