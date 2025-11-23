see also https://github.com/datreeio/CRDs-catalog/blob/main/Utilities/crd-extractor.sh

export FILENAME_FORMAT="{fullgroup}_{kind}_{version}"

.github/helm-template-all-apps-from-target-chart.sh values-kind-delivery.yaml | tee all-resources.yaml

python3 .github/openapi2jsonschema.py all-resources.yaml
