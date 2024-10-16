#!/bin/bash

# just a first draft

get_git_server_url() {

# curl --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" --url "https://gitlabserver/api/v4/projects/namespace%2Fproject/repository/files/install-platform.sh/raw?ref=master"







# https://raw.githubusercontent.com/${CURRENT_REPOSITORY}/${CURRENT_BRANCH}/platform-apps/charts/argocd/manual-secret/argocd-secret.yaml
}

download_file_from




# use cases

# curl -L
# helm install -f
# kubectl apply -f

# build URL with awk:
# URL=https://raw.githubusercontent.com/${CURRENT_REPOSITORY}/${CURRENT_BRANCH}/platform-apps/target-chart/values-$(echo ${TARGET_TYPE} | awk '{print tolower($0)}').yaml


# question:
# why not assume that we first clone our git repo locally and switch to the correct branch and use all files locally?
# (does that also work for github action / gitlab ci? probably yes but lets check)
# which use cases still need a URL download? what about https://github.com/suxess-it/kubriX/blob/main/bootstrap-app-kind-delivery.yaml ?
# what do we need to get the repoURL working?
# what do we need that ARGOCD_APP_SOURCE_REPO_URL and ARGOCD_APP_SOURCE_TARGET_REVISION works?


