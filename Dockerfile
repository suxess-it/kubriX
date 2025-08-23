# docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/suxess-it/kubrix-installer:latest --push .
FROM ubuntu:22.04

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash","-lc"]

# Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq bash coreutils tar gzip unzip procps \
    libnss3-tools \
 && rm -rf /var/lib/apt/lists/*

# yq (select by TARGETARCH)
RUN case "${TARGETARCH}" in \
      amd64) YQ_ARCH=amd64 ;; \
      arm64) YQ_ARCH=arm64 ;; \
      *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac \
 && curl -fsSL -o /usr/local/bin/yq \
      "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH}" \
 && chmod +x /usr/local/bin/yq

# kubectl (select by TARGETARCH)
RUN case "${TARGETARCH}" in \
      amd64) K_ARCH=amd64 ;; \
      arm64) K_ARCH=arm64 ;; \
    esac \
 && KVER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)" \
 && curl -fsSLo /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/${KVER}/bin/linux/${K_ARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl

# Helm (script auto-detects arch)
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# mkcert (needed if target type is KIND; select by TARGETARCH)
RUN case "${TARGETARCH}" in \
      amd64) MC_ARCH=amd64 ;; \
      arm64) MC_ARCH=arm64 ;; \
    esac \
 && MC_VER="$(curl -fsSL https://api.github.com/repos/FiloSottile/mkcert/releases/latest | jq -r '.tag_name')" \
 && curl -fsSLo /tmp/mkcert.tar.gz \
      "https://github.com/FiloSottile/mkcert/releases/download/${MC_VER}/mkcert-${MC_VER}-linux-${MC_ARCH}.tar.gz" \
 && tar -C /usr/local/bin -xzf /tmp/mkcert.tar.gz mkcert \
 && rm -f /tmp/mkcert.tar.gz \
 && chmod +x /usr/local/bin/mkcert

# Put the installer script into the image (Option A)
WORKDIR /work
# Make sure you include install-platform.sh in your build context (same folder as Dockerfile)
COPY install-platform.sh /work/install-platform.sh
RUN chmod +x /work/install-platform.sh

# Non-root default (Job can override if needed)
RUN useradd -m runner && chown -R runner:runner /work
USER runner

# Default run: the Job will set env via Secret and just execute
ENTRYPOINT ["/bin/bash","-lc"]
CMD ["export ARCH=$(uname -m); export OS=$(uname | tr '[:upper:]' '[:lower:]'); /work/install-platform.sh"]
