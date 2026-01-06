#!/usr/bin/env bash
# shellcheck disable=SC2317

__main() {
	{
		_sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')")    # 当前脚本路径
		_dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')                  # 当前目录名
		_pro_name=$(git remote get-url origin | head -n1 | xargs -r basename -s .git) # 当前仓库名
		_image="${_pro_name}:$_dir_name"
	}

	_dockerfile=$(
		cat <<"EOF"
# https://hub.docker.com/_/centos
FROM centos:7
LABEL maintainer="https://github.com/wangsendi"
SHELL ["/bin/bash", "-lc"]

RUN set -eux; \
    echo "配置源和基础环境"; \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && \
    yum makecache && \
    yum install -y ca-certificates curl wget sudo gnupg2 epel-release glibc-devel glibc-static glibc-common tzdata && \
		localedef -i zh_CN -f UTF-8 zh_CN.utf8 || true; \
		localedef -i en_US -f UTF-8 en_US.utf8 || true; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    cat >> /root/.bashrc <<"MEOF"
PS1='\[\033[01;33m\]\u\[\033[00m\]@\[\033[01;35m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
MEOF


RUN set -eux; \
    echo "基础软件包"; \
    yum makecache; \
    yum update -y; \
    yum groupinstall -y "Development tools"; \
    yum install -y \
        tini supervisor cronie vim vim-enhanced vim-common git jq bc tree zip unzip xz tzdata lsof expect tmux perl sshpass \
        util-linux bash-completion dosfstools e2fsprogs parted dos2unix kmod pciutils psmisc \
        openssl openssh-server openssh-clients iptables iproute iputils net-tools ethtool socat telnet mtr rsync ipmitool nfs-utils \
        sysstat iftop htop iotop dstat \
        dmidecode smartmontools lsscsi nvme-cli \
        xorriso cpio file coreutils \
        gzip xz \
        gawk sed grep \
        createrepo_c \
        less mc which \
        libusb-devel libusbx-devel \
        cmake pkgconfig gcc make \
        autoconf automake libtool \
        strace traceroute man-db \
        filesystem \
        libmpc-devel mpfr-devel gmp-devel gcc-c++ gcc-c++-devel zlib-devel zlib \
        glibc-devel.i686 glibc-i686; \
    yum clean all; \
    rm -rf /var/cache/yum/*; \
    echo;

RUN set -eux; \
    echo "软链接和SSH配置"; \
    rm -rf /etc/cron.d/ && \
    ln -sf /apps/data/cron.d/ /etc/cron.d && \
    ln -sf /bin/bash /bin/sh && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "StrictHostKeyChecking no" >> /root/.ssh/config;

RUN set -eux; \
    cd /tmp && \
    wget -q https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz || \
    wget -q https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz && \
    tar xfz gcc-8.2.0.tar.gz && \
    cd gcc-8.2.0 && \
    ./configure --with-system-zlib --disable-multilib --enable-languages=c,c++ && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/gcc-8.2.0 /tmp/gcc-8.2.0.tar.gz /usr/local/lib/../lib64/libstdc++.so.6.0.24-gdb.py && \
    echo;

RUN set -eux; \
    cd /tmp; \
    wget -q https://ftp.gnu.org/gnu/make/make-4.3.tar.gz || \
    wget -q https://mirrors.tuna.tsinghua.edu.cn/gnu/make/make-4.3.tar.gz; \
    tar -xzf make-4.3.tar.gz; \
    cd make-4.3; \
    ./configure --prefix=/usr/local/make; \
    make -j$(nproc); \
    make install; \
    mv /usr/bin/make /usr/bin/make.bak; \
    ln -sf /usr/local/make/bin/make /usr/bin/make; \
    cd /; \
    rm -rf /tmp/make-4.3 /tmp/make-4.3.tar.gz; \
    echo;

# Update GLIBC
RUN set +eux; \
    cd /tmp && \
    wget -q https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz || \
    wget -q https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/glibc-2.28.tar.gz || true; \
    tar -xvzf glibc-2.28.tar.gz 2>/dev/null || true; \
    cd glibc-2.28 2>/dev/null && \
    mkdir -p glibc-build && \
    cd glibc-build && \
    ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin 2>&1 || true; \
    make -j$(nproc) 2>&1 || true; \
    make install 2>&1 || true; \
    cd / && \
    rm -rf /tmp/glibc-2.28 /tmp/glibc-2.28.tar.gz 2>/dev/null || true; \
    echo "glibc 2.28 安装完成（可能包含警告）"

ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"

RUN set +eux; \
    [ -f /usr/local/lib64/libstdc++.so.6.0.25 ] && \
    ln -sf /usr/local/lib64/libstdc++.so.6.0.25 /usr/lib64/libstdc++.so.6.0.25 && \
    ln -sf libstdc++.so.6.0.25 /usr/lib64/libstdc++.so.6 && \
    echo "libstdc++ 6.0.25 已链接" || \
    echo "libstdc++ 6.0.25 未找到，跳过链接"

COPY apps/files/etc/ld.so.conf.d/local-lib64.conf /etc/ld.so.conf.d/local-lib64.conf
COPY apps/files/etc/ld.so.conf.d/local-lib.conf /etc/ld.so.conf.d/local-lib.conf
RUN ldconfig 

ENV PATH=/root/.local/bin:/root/go/bin:$PATH
ENV TZ=Asia/Shanghai
ENV IS_SANDBOX=1
ENV LANG=en_US.UTF-8

WORKDIR /apps/data
COPY apps/ /apps/
ENTRYPOINT ["tini", "--"]
CMD ["sh", "-c", "bash /apps/.entry.sh"]

LABEL org.opencontainers.image.source=$_ghcr_source
LABEL org.opencontainers.image.description="专为 CentOS ISO 构建环境"
LABEL org.opencontainers.image.licenses=MIT
EOF
	)
	{
		cd "$(dirname "$_sh_path")" || exit 1
		echo "$_dockerfile" >Dockerfile

		_ghcr_source=$(git remote get-url origin | head -n1 | sed 's|git@github.com:|https://github.com/|' | sed 's|.git$||')
		sed -i "s|\$_ghcr_source|$_ghcr_source|g" Dockerfile
	}
	{
		if command -v sponge >/dev/null 2>&1; then
			jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json
		else
			jq 'del(.credsStore)' ~/.docker/config.json >~/.docker/config.json.tmp && mv ~/.docker/config.json.tmp ~/.docker/config.json
		fi
	}
	{
		_registry="ghcr.io/wangsendi" # 托管平台, 如果是 docker.io 则可以只填写用户名
		_repository="$_registry/$_image"
		_buildcache="$_registry/$_pro_name:cache"
		echo "image: $_repository"
		echo "cache: $_buildcache"
		echo "-----------------------------------"
		docker buildx build --builder default --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
			# true/false
			if false; then
				docker rm -f sss
				docker run -itd --name=sss \
					--restart=always \
					--network=host \
					--privileged=false \
					"$_repository"
				docker exec -it sss bash
			fi
		}
		docker push "$_repository"

	}
}

__main

__help() {
	cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/wangsendi/cr-iso-builder:centos-latest

yum install -y devtoolset-8-*


EOF
}
