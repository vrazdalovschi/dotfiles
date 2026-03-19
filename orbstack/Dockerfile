FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# --- System packages ---
RUN apt-get update && apt-get install -y \
    zsh git curl wget build-essential ca-certificates gnupg sudo \
    tree dos2unix jq btop watch unzip tealdeer locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# --- Google Cloud CLI ---
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        | tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null \
    && apt-get update && apt-get install -y google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# --- Docker CLI (for docker-in-docker via socket mount) ---
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# --- mise (runtime/tool manager) ---
RUN curl https://mise.run | sh
ENV PATH="/root/.local/share/mise/shims:/root/.local/share/mise/bin:/root/.local/bin:${PATH}"
ENV IS_SANDBOX=1

# All dev runtimes and CLI tools via mise
COPY mise.toml /root/.config/mise/config.toml
RUN --mount=type=secret,id=github_token \
    GITHUB_TOKEN=$(cat /run/secrets/github_token 2>/dev/null || true) \
    mise install -y && mise reshim

# --- Claude Code (native installer) ---
RUN curl -fsSL https://claude.ai/install.sh | bash

# --- Zsh plugins ---
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /usr/share/zsh-syntax-highlighting \
    && git clone --depth=1 https://github.com/MichaelAquilina/zsh-you-should-use /usr/share/zsh-you-should-use

# --- Shell config ---
COPY sandbox.zshrc /root/.zshrc
RUN chsh -s /bin/zsh

WORKDIR /workspace
