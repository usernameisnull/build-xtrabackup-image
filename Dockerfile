# Dockerfile for compiling Percona XtraBackup 8.0 on CentOS 8.3

# 使用用户指定的基础镜像
FROM centos:8.3.2011
# 1. 定义构建参数，用于接收 XtraBackup 的 Git Tag 或分支名
# 默认值设置为 '8.0.35-31'
ARG XTRABACKUP_TAG=8.0.35-31

# 安装路径
ENV INSTALL_PATH /usr/local/xtrabackup
# 设置 xtrabackup 二进制文件的环境变量
ENV PATH="${INSTALL_PATH}/bin:${PATH}"

# 安装编译所需的依赖包
# 依赖列表参考 Percona 官方文档 (yum/dnf)
RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y \
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
    dnf clean all && \
    rm -rf /var/cache/dnf

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
RUN dnf remove -y git cmake automake autoconf bison libtool gcc-c++ && \
    dnf clean all && \
    rm -rf /usr/src/percona-xtrabackup /var/cache/dnf

# 设置默认命令，验证安装是否成功
CMD ["xtrabackup", "--version"]