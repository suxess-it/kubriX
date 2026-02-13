#!/usr/bin/env bash
set -euo pipefail

# Generates an SBOM (CycloneDX JSON) per image using Trivy
# and writes a license summary report (TSV) + per-image license files.
#
# Requirements: jq, trivy, (optional) docker/nerdctl access to pull images

IMAGE_LIST_FILE="${IMAGE_LIST_FILE:-image-list/image-list.json}"
OUT_DIR="${OUT_DIR:-image-list/trivy-sbom-out}"
SBOM_DIR="${SBOM_DIR:-$OUT_DIR/sboms}"
# LICENSE_DIR="${LICENSE_DIR:-$OUT_DIR/licenses}"
# REPORT_TSV="${REPORT_TSV:-$OUT_DIR/licenses-per-image.tsv}"

mkdir -p "$SBOM_DIR" # "$LICENSE_DIR"
# empty files
rm -f "$SBOM_DIR"/*

# : > "$REPORT_TSV"

# install trivy
curl -L https://github.com/aquasecurity/trivy/releases/download/v0.69.0/trivy_0.69.0_Linux-32bit.tar.gz -o trivy.tar.gz
tar -xzvf trivy.tar.gz trivy
chmod u+x trivy

# install parlay
curl -L https://github.com/snyk/parlay/releases/download/v0.10.1/parlay_Linux_x86_64.tar.gz -o parlay.tar.gz
tar -xzvf parlay.tar.gz parlay
chmod u+x parlay

export PATH=$PATH:$(pwd)

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing required tool: $1" >&2; exit 1; }; }
need jq
need trivy
need parlay

if [[ ! -f "$IMAGE_LIST_FILE" ]]; then
  echo "ERROR: image list file not found: $IMAGE_LIST_FILE" >&2
  exit 1
fi

# echo -e "image\tcharts\tlicenses\tcomponents_with_license\tcomponents_total\tsbom_file" >> "$REPORT_TSV"

# Helper: sanitize an image ref into a filesystem-friendly filename
sanitize() {
  echo "$1" | sed -E 's/[^A-Za-z0-9._-]+/_/g'
}

# Build a unique image list
mapfile -t IMAGES < <(jq -r '.[].image' "$IMAGE_LIST_FILE" | sort -u)

echo "Found ${#IMAGES[@]} unique images."

for image in "${IMAGES[@]}"; do
  safe="$(sanitize "$image")"
  sbom_file="$SBOM_DIR/${safe}.cdx.json"

  # Find which charts referenced this image (may be multiple)
  charts="$(jq -r --arg img "$image" '[.[] | select(.image==$img) | .chart] | unique | join(",")' "$IMAGE_LIST_FILE")"
  [[ -n "$charts" ]] || charts="-"

  echo "==> SBOM: $image"
  if ! trivy image --quiet --format cyclonedx --output "$sbom_file" "$image"; then
    echo "WARN: trivy failed for $image (skipping license extraction)" >&2
    # echo -e "${image}\t${charts}\tTRIVY_FAILED\t0\t0\t${sbom_file}" >> "$REPORT_TSV"
    continue
  else
    parlay ecosystems enrich "$sbom_file" | jq  > "${sbom_file}.parlay"
    mv ${sbom_file}.parlay ${sbom_file}
  fi


# CycloneDX license extraction - not needed at the moment
#  components_total="$(jq -r '(.components // []) | length' "$sbom_file")"
#
#  components_with_license="$(jq -r '
#    (.components // [])
#    | map(select((.licenses // []) | length > 0))
#    | length
#  ' "$sbom_file")"

#  jq -r '
#    (.components // [])
#    | .[]
#    | (.licenses // [])
#    | .[]
#    | (
#        .license.id? // .license.name? // empty
#      )
#  ' "$sbom_file" \
#  | sed '/^$/d' \
#  | sort -u > "$lic_file"

#  if [[ -s "$lic_file" ]]; then
#    licenses_csv="$(paste -sd, "$lic_file")"
#  else
#    licenses_csv="(none-found)"
#  fi

#  echo -e "${image}\t${charts}\t${licenses_csv}\t${components_with_license}\t${components_total}\t${sbom_file}" >> "$REPORT_TSV"
done

echo
echo "Done."
# echo "Report:   $REPORT_TSV"
echo "SBOMs:    $SBOM_DIR"
# echo "Licenses: $LICENSE_DIR"
