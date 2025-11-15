FROM ubuntu:18.04
WORKDIR /root
RUN apt-get update -y \
    && apt-get install -y wget  \
    unzip \
    build-essential \
    flex \
    bison \
    automake \
    autoconf \
    libtool \
    cmake \
    libaio-dev \
    mysql-client \
    libncurses-dev \
    zlib1g-dev \
    libgcrypt11-dev \
    libev-dev \
    libcurl4-gnutls-dev \
    vim-common \
    libssl-dev
RUN mkdir /root/boost \
    && wget -qO /root/boost/boost_1_59_0.tar.gz https://archives.boost.io/release/1.59.0/source/boost_1_59_0.tar.gz
RUN wget -qO /root/percona-xtrabackup-2.4.26.zip https://github.com/percona/percona-xtrabackup/archive/refs/tags/percona-xtrabackup-2.4.26.zip \
    && unzip -q percona-xtrabackup-2.4.26.zip \
    && cd percona-xtrabackup-percona-xtrabackup-2.4.26 \
    && mkdir build \
    && cd build  \
    && cmake \
      -DWITH_BOOST=/root/boost \
      -DDOWNLOAD_BOOST=OFF \
      -DBUILD_CONFIG=xtrabackup_release \
      -DWITH_MAN_PAGES=OFF \
      -B .. \
    && make \
    && make install
ENV PATH="/usr/local/xtrabackup/bin:${PATH}"

