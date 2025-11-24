see also https://github.com/datreeio/CRDs-catalog/blob/main/Utilities/crd-extractor.sh

export FILENAME_FORMAT="{fullgroup}_{kind}_{version}"

.github/helm-template-all-apps-from-target-chart.sh values-kind-delivery.yaml | tee all-resources.yaml

python3 .github/openapi2jsonschema.py all-resources.yaml


# just some notes, actually we need to to use https://github.com/datreeio/CRDs-catalog/blob/main/Utilities/crd-extractor.sh
#   because not all CRDs are really created with helm template, crossplane CRDs are created during runtime via the crossplane operator

# create directory
for dir in $( for file in $( find . -type f ) ; do echo $file ; done | awk -F_ '{print $1}' | awk -F/ '{print $2}' |sort -u ) ; do mkdir ${dir} ; done


# rename files
for file in $( find . -type f ) ; do newfilename=$( echo $file | awk -F_ '{print $2 "_" $3 }'); mv $file $newfilename ; done