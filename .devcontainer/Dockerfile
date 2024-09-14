# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile
FROM quay.io/akuity/argo-cd-learning-assets/akuity-devcontainer:0.2.3

# Select desired TAG from https://github.com/argoproj/argo-cd/releases
ENV ARGOCD_VERSION=v2.11.0
RUN curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
    && chmod +x /usr/local/bin/argocd