# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile
FROM quay.io/akuity/argo-cd-learning-assets/akuity-devcontainer:0.2.5

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends skopeo \
 && rm -rf /var/lib/apt/lists/*
