#!/usr/bin/env bash
set -euo pipefail

version=v0.76.2
archive="trivy_${version#v}_Linux-64bit.tar.gz"
checksums="trivy_${version#v}_checksums.txt"
release_url="https://github.com/aquasecurity/trivy/releases/download/${version}"
download_dir=$(mktemp -d)
trap 'rm -rf "$download_dir"' EXIT

cd "$download_dir"
curl --fail --silent --show-error --location --retry 3 --output "$archive" "$release_url/$archive"
curl --fail --silent --show-error --location --retry 3 --output "$checksums" "$release_url/$checksums"
awk -v archive="$archive" '$2 == archive {print}' "$checksums" | sha256sum --check --strict
tar -xzf "$archive" trivy

bin_dir="$RUNNER_TEMP/trivy-bin"
install -D -m 0755 trivy "$bin_dir/trivy"
"$bin_dir/trivy" --version
echo "$bin_dir" >> "$GITHUB_PATH"
