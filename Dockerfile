# docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/suxess-it/kubrix-installer:latest --push .
FROM ubuntu:24.04

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash","-lc"]

ARG VERSION=unknown
ARG VCS_REF=unknown

# Make it available in several ways
ENV APP_VERSION="${VERSION}" \
    VCS_REF="${VCS_REF}"

# Optional: a tiny metadata file that's easy to cat
RUN printf "version=%s\nrevision=%s\n" "$APP_VERSION" "$VCS_REF" > /etc/image-version
RUN chmod a+r /etc/image-version

# OCI labels (useful for docker inspect / registries)
LABEL org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.version="$APP_VERSION"

# Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg git jq bash coreutils tar gzip unzip procps \
    libnss3-tools util-linux bsdextrautils gettext-base gawk grep sed \
    iproute2 iputils-ping dnsutils openssl \
    apache2-utils \
    mkcert \
 && rm -rf /var/lib/apt/lists/*

# gomplate
COPY --from=hairyhenderson/gomplate:stable /gomplate /usr/local/bin/gomplate

# k8sgpt
COPY --from=ghcr.io/k8sgpt-ai/k8sgpt:v0.4.26 /k8sgpt /usr/local/bin/k8sgpt

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

# Helm
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
 && echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
    > /etc/apt/sources.list.d/helm-stable-debian.list \
 && apt-get update && apt-get install -y --no-install-recommends helm \
 && rm -rf /var/lib/apt/lists/*

# Put the installer script into the image (Option A)
WORKDIR /work
# Make sure you include install-platform.sh in your build context (same folder as Dockerfile)
COPY install-platform.sh /work/install-platform.sh
RUN chmod +x /work/install-platform.sh
ENV KUBRIX_INSTALLER=true

# Use a stable, shared CAROOT inside the image (readable to non-root)
ENV CAROOT=/etc/mkcert
RUN mkdir -p "$CAROOT" \
 && mkcert -install \
 && chmod -R a+rX "$CAROOT"

# (optional but handy) make mkcert skip failing -install later if CA already exists
RUN mv /usr/bin/mkcert /usr/bin/mkcert.real && \
    cat >/usr/bin/mkcert <<'EOF' && \
    chmod +x /usr/bin/mkcert
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == "-install" || "$1" == "install" ]]; then
  if [[ -f "${CAROOT:-/etc/mkcert}/rootCA-key.pem" ]]; then
    echo "mkcert: CA already installed, skipping."
    exit 0
  fi
fi
exec /usr/bin/mkcert.real "$@"
EOF

# Non-root default (Job can override if needed)
RUN useradd -m runner && chown -R runner:runner /work
USER runner

# Default run: the Job will set env via Secret and just execute
ENTRYPOINT ["/bin/bash","-lc"]
CMD ["export ARCH=$(uname -m); export OS=$(uname | tr '[:upper:]' '[:lower:]'); /work/install-platform.sh"]
