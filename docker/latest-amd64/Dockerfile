# https://hub.docker.com/_/ubuntu
FROM ubuntu:noble-20251013
LABEL maintainer="https://github.com/lwmacct"
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]

RUN set -eux; \
    echo "配置源,容器内源文件为 /etc/apt/sources.list.d/ubuntu.sources"; \
    sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources; \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get update; apt-get install -y --no-install-recommends ca-certificates curl wget sudo pcp gnupg; \
    sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo "设置 PS1"; \
    cat >> /root/.bashrc <<"MEOF"
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[00m\]@\[\033[01;35m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
MEOF

RUN set -eux; \
    echo "语言/时间"; \
    apt-get update; \
    apt-get install -y --no-install-recommends locales fonts-wqy-zenhei fonts-wqy-microhei tzdata; \
    locale-gen zh_CN.UTF-8 en_US.UTF-8; \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo;

RUN set -eux; \
    echo "基础软件包"; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
        tini supervisor cron vim git jq bc tree zstd zip unzip xz-utils tzdata lsof expect tmux perl sshpass  \
        util-linux bash-completion dosfstools e2fsprogs parted dos2unix kmod pciutils moreutils psmisc \
        openssl openssh-server nftables iptables iproute2 iputils-ping net-tools ethtool socat telnet mtr rsync ipmitool nfs-common \
        sysstat iftop htop iotop dstat \
        ipmitool dmidecode smartmontools hardinfo lsscsi nvme-cli ; \
    rm -rf /*-is-merged; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo;

RUN set -eux; \
    echo 'install oh-my-zsh'; \
    git clone https://github.com/ohmyzsh/ohmyzsh.git /opt/ohmyzsh; \
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /opt/ohmyzsh/custom/plugins/zsh-autosuggestions; \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /opt/ohmyzsh/custom/plugins/zsh-syntax-highlighting; \
    git clone https://github.com/zsh-users/zsh-completions.git /opt/ohmyzsh/custom/plugins/zsh-completions; \
    git clone https://github.com/jimhester/per-directory-history.git /opt/ohmyzsh/custom/plugins/per-directory-history; \
    git clone https://github.com/zsh-users/zsh-history-substring-search.git /opt/ohmyzsh/custom/plugins/zsh-history-substring-search; \
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git /opt/ohmyzsh/custom/plugins/you-should-use; \
    git clone https://github.com/changyuheng/zsh-interactive-cd.git /opt/ohmyzsh/custom/plugins/zsh-interactive-cd; \
    git clone https://github.com/romkatv/powerlevel10k.git /opt/ohmyzsh/custom/themes/powerlevel10k; \
    find /opt/ohmyzsh/ -type d -name '.git'; \
    find /opt/ohmyzsh/ -type d -name '.git' | xargs -r rm -rf;

# https://github.com/etcd-io/etcd
# curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest | jq -r '.tag_name'
COPY --from=gcr.io/etcd-development/etcd:v3.6.7 /usr/local/bin/etcdctl /usr/local/bin/etcdctl

RUN set -eux; \
    echo 'https://github.com/cli/cli#installation'; \
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y; \
    rm -rf  /usr/share/keyrings/githubcli-archive-keyring.gpg /etc/apt/sources.list.d/github-cli.list; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

# https://github.com/nektos/act
RUN set -eux; \
    echo "安装 act https://github.com/nektos/act"; \
    _tag_name=$(curl -s https://api.github.com/repos/nektos/act/releases/latest | jq -r '.tag_name'); \
    echo "获取到 act 最新版本: $_tag_name"; \
    mkdir -p /tmp/act-install; \
    _arch="x86_64"; \
    wget -qO- "https://github.com/nektos/act/releases/download/$_tag_name/act_Linux_${_arch}.tar.gz" | tar -xzf - -C /tmp/act-install; \
    mv /tmp/act-install/act /usr/local/bin/act; \
    chmod +x /usr/local/bin/act; \
    rm -rf /tmp/act-install; \
    act --version;

RUN set -eux; \
    echo "安装 docker-cli https://docs.docker.com/engine/install/ubuntu/"; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null; \
    apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin docker-buildx-plugin; \
    rm -rf /etc/apt/sources.list.d/docker.list; \
    rm -rf /etc/apt/keyrings/docker.asc; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

RUN set -eux; \
    echo "安装 fluent-bit"; \
    curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

ARG GOPROXY=https://goproxy.cn,direct
ARG GO111MODULE=on
RUN set -eux; \
    echo "安装 Golang https://go.dev/dl/"; \
    _go_version=$(curl -sSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version'); \
    echo "获取到 Golang 最新版本: $_go_version"; \
    curl -Lo - "https://go.dev/dl/$_go_version.linux-amd64.tar.gz" | tar zxf - -C /usr/local/;

RUN set -eux; \
    echo "常用包安装"; \
    apt-get update; apt-get install -y --no-install-recommends \
        bpfcc-tools linux-tools-common \
        build-essential gcc make cmake automake ninja-build shc upx \
        file strace ltrace valgrind netcat-openbsd \
        git-lfs cron direnv shellcheck fzf zfsutils-linux xxd \
        zsh redis-tools openssh-client supervisor \
        xarclock xvfb x11vnc dbus-x11 \
        dnsutils \
        asciinema \
        umoci skopeo \
        ffmpeg \
        ripgrep fd-find \
        ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

RUN set -eux; \
    echo "python"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv python3-dotenv \
        python3-yaml \
        python3-requests python3-requests-unixsocket \
        python3-openssl python3-bcrypt; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;


RUN set -eux; \
    echo "安装 uv"; \
    _arch="x86_64"; \
    _tag_name=$(curl -s https://api.github.com/repos/astral-sh/uv/releases/latest | jq -r '.tag_name'); \
    echo "获取到 uv 最新版本: $_tag_name"; \
    wget -qO- "https://github.com/astral-sh/uv/releases/download/$_tag_name/uv-${_arch}-unknown-linux-gnu.tar.gz" | tar -xzf - -C /tmp; \
    mv /tmp/uv-${_arch}-unknown-linux-gnu/uv /usr/local/bin/uv; \
    mv /tmp/uv-${_arch}-unknown-linux-gnu/uvx /usr/local/bin/uvx; \
    chmod +x /usr/local/bin/uv /usr/local/bin/uvx; \
    rm -rf /tmp/uv-${_arch}-unknown-linux-gnu; \
    uv venv /opt/venv --system-site-packages; \
    uv pip install --python /opt/venv/bin/python --upgrade pip pre_commit black isort ruff rich textual mcp-proxy md-toc; \
    /opt/venv/bin/pip config set global.index-url https://mirrors.ustc.edu.cn/pypi/simple; \
    uv -V; \
    echo;

ENV NVM_DIR=/opt/nvm 
ENV NODE_VERSION="lts/*"
RUN set -eux; \
  echo "安装 nvm + Node LTS"; \
  _tag_name=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name'); \
  echo "获取到 nvm 最新版本: $_tag_name"; \
  mkdir -p "$NVM_DIR" \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$_tag_name/install.sh | PROFILE=/dev/null bash \
  && source "$NVM_DIR/nvm.sh" \
  && nvm install "$NODE_VERSION" \
  && nvm alias default "$NODE_VERSION" \
  && node -v && npm -v; \
  echo; \
  echo "登录/交互式 bash 自动加载 nvm"; \
  printf 'export NVM_DIR="/opt/nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n' > /etc/profile.d/nvm.sh; \
  grep -q 'profile.d/nvm.sh' /etc/bash.bashrc || echo '[ -f /etc/profile.d/nvm.sh ] && . /etc/profile.d/nvm.sh' >> /etc/bash.bashrc; \
  echo; \
  echo "非交互 bash 自动加载 nvm"; \
  cat /etc/profile.d/nvm.sh >> /etc/bash_env; \
  echo;

ENV BASH_ENV=/etc/bash_env

RUN set -eux; \
    npm -v; \
    npm install -g npm@latest; \
    npm -v; \
    echo "Configuring npm to minimize cache"; \
    npm config set cache /tmp/npm-cache; \
    npm config set prefer-offline false; \
    echo "Installing global npm packages"; \
    npm install -g --no-cache \
        vitest \
        degit \
        vue-tsc \
        yarn \
        pnpm \
        bun \
        pm2 \
        prettier \
        typescript \
        wrangler \
        npm-check-updates \
        @antfu/ni \
        @go-task/cli; \
    echo "Cleaning npm cache and temporary files"; \
    npm cache clean --force; \
    rm -rf ~/.npm /tmp/npm-cache

RUN set -eux; \
    echo "update"; \
    echo "https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md"; \
    npm config set cache /tmp/npm-cache; \
    npm install -g --no-cache @openai/codex @anthropic-ai/claude-code @google/gemini-cli; \
    npm cache clean --force; \
    rm -rf ~/.npm /tmp/npm-cache

RUN echo "软链接 cron.d" ; \
    rm -rf /etc/cron.d/; \
    ln -sf /apps/data/cron.d/ /etc/cron.d; \
    ln -sf /bin/bash /bin/sh; \
    ln -sf /usr/bin/fdfind /usr/bin/fd; \
    mkdir -p /root/.ssh; \
    chmod 700 /root/.ssh; \
    echo "StrictHostKeyChecking no" >> /root/.ssh/config;

ENV PATH=/root/.local/bin:/usr/local/go/bin:/opt/venv/bin:/opt/fluent-bit/bin:/root/go/bin:$PATH
ENV TZ=Asia/Shanghai
ENV IS_SANDBOX=1
ENV UV_LINK_MODE=copy
ENV PYTHONDONTWRITEBYTECODE=1
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on
ENV TASK_REMOTE_DIR=/root/.cache/taskfile
ENV TASK_X_REMOTE_TASKFILES=1

WORKDIR /apps/data
COPY apps/ /apps/
ENTRYPOINT ["tini", "--"]
CMD ["sh", "-c", "bash /apps/.entry.sh"]

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250812-cr-vscode
LABEL org.opencontainers.image.description="专为 VSCode 容器开发环境构建"
LABEL org.opencontainers.image.licenses=MIT
