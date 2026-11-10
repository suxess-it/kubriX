#!/usr/bin/env bash
# Wait for transient GitHub API TLS failures before creating an App installation
# token. This checks connectivity only; it does not retry token creation itself.
set -euo pipefail

url="https://api.github.com/rate_limit"
delays=(15 30 60)

for attempt in 1 2 3 4; do
  if curl --silent --show-error --fail --connect-timeout 10 --max-time 20 \
      --output /dev/null "$url"; then
    echo "GitHub API HTTPS connectivity OK (attempt ${attempt}/4)"
    exit 0
  fi

  if (( attempt == 4 )); then
    echo "::error::GitHub API HTTPS connectivity unavailable after 4 attempts"
    exit 1
  fi

  delay="${delays[$((attempt - 1))]}"
  echo "::warning::GitHub API HTTPS connectivity failed (attempt ${attempt}/4); retrying in ${delay}s"
  sleep "$delay"
done
