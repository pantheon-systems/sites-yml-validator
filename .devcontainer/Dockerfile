FROM mcr.microsoft.com/devcontainers/go:1.21-bookworm

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN \
    echo "deb [signed-by=/etc/apt/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" \
        | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        > /etc/apt/keyrings/cloud.google.asc \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        curl \
        dh-autoreconf \
        fuse \
        google-cloud-cli \
        google-cloud-sdk-gke-gcloud-auth-plugin \
        kubernetes-client \
        libfuse-dev \
        libglib2.0-dev \
        libjemalloc-dev \
        libleveldb-dev \
        libsystemd-dev \
        liburiparser-dev \
        npm \
        podman \
        shellcheck \
        sudo \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/*

RUN \
    rm -f /usr/local/bin/hadolint \
    && curl -fsSL https://api.github.com/repos/hadolint/hadolint/releases/latest \
        | jq '.assets[] | select(.name=="hadolint-Linux-x86_64") | .browser_download_url' \
        | xargs curl -fsS -o /usr/local/bin/hadolint -L \
    && chmod 0755 /usr/local/bin/hadolint

# hadolint ignore=DL3016
RUN \
    npm install --save markdown-toc --global

# uid/gid may be changed at runtime.
USER vscode

RUN \
    mkdir -p "${HOME}/.kube" \
    && go install github.com/mfridman/tparse@latest
