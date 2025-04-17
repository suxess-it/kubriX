#!/bin/bash

set -e

# install trivy
curl -L https://github.com/aquasecurity/trivy/releases/download/v0.61.0/trivy_0.61.0_Linux-32bit.tar.gz -o trivy.tar.gz
tar -xzvf trivy.tar.gz trivy
chmod u+x trivy

# install helm images plugin
helm plugin install https://github.com/nikhilsbhat/helm-images

# get changed charts between main and PR
changed_charts=$( diff -qr pr/platform-apps/charts target/platform-apps/charts | grep -v "platform-apps/charts/image-list" | awk -F/ '{print $4}' | sort -u )

if [[ "${changed_charts}" == "" ]]; then
  echo "no changes"
  echo "CHANGES=false" >> $GITHUB_ENV
  exit 0
else
  echo "CHANGES=true" >> $GITHUB_ENV
fi

echo "charts which differ between main and PR:"
echo "${changed_charts}"

# get images for this charts to see if also the images changed
mkdir -p out/pr
mkdir -p out/target
for env in pr target; do
  cd ${env}/platform-apps/charts
  for chart in ${changed_charts}; do
    echo "get images for chart: ${chart}"
    helm dependency update ${chart}
    for value in $( find ${chart} -type f -name "values-*" ); do
      helm images get ${chart} -f ${value} --log-level error --kind "Deployment,StatefulSet,DaemonSet,CronJob,Job,ReplicaSet,Pod,Alertmanager,Prometheus,ThanosRuler,Grafana,Thanos,Receiver"
    done | sort -u > ../../../out/${env}/${chart}-images.txt
  done
  cd -
done
changed_images_charts=$( diff -q out/target out/pr | awk '{print $2}' | awk -F/ '{print $3}' | sed 's/-images.txt//g' )

echo "charts where images changed between PR and main:"
echo "${changed_images_charts}"

# create trivy scan reports per image to see if the scan reports changed
for chart in ${changed_images_charts} ; do
  mkdir -p out/pr/scans/${chart}
  mkdir -p out/target/scans/${chart}
  for env in pr target; do
    for image in $(cat out/${env}/${chart}-images.txt) ; do
      output_file=$( echo -n "${chart}_$( echo ${image} | awk -F/ '{print $NF}' )" )
      ./trivy image --scanners vuln -f template --template "@pr/trivy-reports/markdown.tpl" -o out/${env}/scans/${chart}/${output_file}.md ${image}
      # append file to a scan output per chart to better compare them 
      cat out/${env}/scans/${chart}/${output_file}.md >> out/${env}/scans/${chart}/scan_summary.md
      rm out/${env}/scans/${chart}/${output_file}.md
    done
  done
done


 diff -U 4 -r out/target/scans out/pr/scans > out/scan-diff.txt || true

sed  's/DESCRIPTION_HERE/Changes Trivy Scan/g' pr/.github/pr-diff-template.txt > out/comment-diff-trivy-scan.txt
sed  -e "/DIFF_HERE/{r out/scan-diff.txt" -e "d}" out/comment-diff-trivy-scan.txt > out/comment-diff-trivy-scan-result.txt
