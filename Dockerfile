FROM centos:8.3.2011

# 安装必要工具及编译依赖
RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install \
      git \
      cmake \
      gcc \
      gcc-c++ \
      bison \
      pkgconfig \
      openssl-devel \
      libaio libaio-devel \
      automake \
      autoconf \
      libtool \
      ncurses-devel \
      libgcrypt-devel \
      libev-devel \
      libcurl-devel \
      zlib-devel \
      zstd \
      lz4 \
      vim-common \
      procps-ng-devel \
      python3-sphinx \
      make && \
    # 若 cmake 默认版本 <3，可安装 cmake3 或从源码安装
    cmake --version

# 克隆源码
RUN git clone https://github.com/percona/percona-xtrabackup.git /usr/src/percona-xtrabackup && \
    cd /usr/src/percona-xtrabackup && \
    git checkout 8.0 && \
    git submodule update --init --recursive

WORKDIR /usr/src/percona-xtrabackup

# 创建 build 目录并运行 cmake 生成构建管道
RUN mkdir build && cd build && \
    cmake -DWITH_BOOST=../boost \
          -DDOWNLOAD_BOOST=ON \
          -DBUILD_CONFIG=xtrabackup_release \
          -DWITH_MAN_PAGES=OFF \
          -B ..

# 编译
RUN cd build && \
    make -j$(nproc)

# 安装
RUN cd build && \
    make install

# 添加 PATH 如有需要
ENV PATH="/usr/local/xtrabackup/bin:${PATH}"

# 最终镜像清理（可选）
RUN dnf -y clean all && \
    rm -rf /var/cache/dnf && \
    rm -rf /usr/src/percona-xtrabackup

CMD ["xtrabackup", "--version"]
