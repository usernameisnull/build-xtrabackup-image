# Dockerfile for compiling Percona XtraBackup from a dynamic Git Tag

FROM centos:8.3.2011
ARG XTRABACKUP_TAG=8.0.35-31

# 设置环境变量...
ENV INSTALL_PATH /usr/local/xtrabackup
ENV PATH="${INSTALL_PATH}/bin:${PATH}"

# --- 解决 CentOS 8 源失效的关键步骤 ---
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum makecache

# 安装编译所需的依赖包
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y \
        git \
        cmake \
        openssl-devel \
        libaio \
        libaio-devel \
        automake \
        autoconf \
        bison \
        libtool \
        ncurses-devel \
        libgcrypt-devel \
        libev-devel \
        libcurl-devel \
        zlib-devel \
        procps-ng-devel \
        zstd \
        make \
        gcc-c++ \
        vim-common \
        pkg-config && \
    yum clean all && \
    rm -rf /var/cache/yum

# 克隆并编译 Percona XtraBackup
WORKDIR /usr/src

# 1. 克隆代码
RUN git clone https://github.com/percona/percona-xtrabackup.git && \
    cd percona-xtrabackup && \
    # 切换到 8.0 分支
    git checkout ${XTRABACKUP_TAG} && \
    # 初始化子模块，获取依赖
    git submodule update --init --recursive

# 2. 配置和编译
WORKDIR /usr/src/percona-xtrabackup
RUN mkdir build && \
    cd build && \
    # 使用 cmake 配置，自动下载并使用 Boost 库，并构建发布版本
    cmake -DWITH_BOOST=./boost_src -DDOWNLOAD_BOOST=ON \
          -DBUILD_CONFIG=xtrabackup_release \
          -DWITH_MAN_PAGES=OFF \
          -B .. && \
    # 编译（使用所有核心加速）
    make -j$(nproc) && \
    # 安装到 /usr/local/xtrabackup
    make install

# 3. 清理构建工具和源代码，减小最终镜像体积
# 注意：只移除构建依赖（如 git, cmake, gcc-c++），运行时依赖（如 libaio, libcurl）保留
RUN yum remove -y git cmake automake autoconf bison libtool gcc-c++ && \
    yum clean all && \
    rm -rf /usr/src/percona-xtrabackup /var/cache/yum

# 设置默认命令，验证安装是否成功
CMD ["xtrabackup", "--version"]