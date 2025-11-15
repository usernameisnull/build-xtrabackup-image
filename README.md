8.0: https://docs.percona.com/percona-xtrabackup/8.0/compile-xtrabackup.html#1-install-percona-xtrabackup-from-the-git-source-tree
2.4: https://docs.percona.com/percona-xtrabackup/2.4/installation/compiling_xtrabackup.html
other doc: https://github.com/ddev/ddev/issues/3002#issuecomment-945157066

[root@ms1112-mysql-0 /]# xtrabackup -v
xtrabackup: recognized server arguments: --innodb_file_per_table=1 --innodb_flush_log_at_trx_commit=2 --innodb_flush_method=O_DIRECT --innodb_log_files_in_group=2 --log_bin=/var/lib/mysql/mysql-bin --open_
files_limit=65535 --innodb_log_file_size=48M --server-id=100
xtrabackup version 2.4.26 based on MySQL server 5.7.35 Linux (x86_64) (revision id: )

wget https://github.com/percona/percona-xtrabackup

## percona-xtrabackup-2.4.26
编译arm版  
wget -O percona-xtrabackup-2.4.26.zip https://github.com/percona/percona-xtrabackup/archive/refs/tags/percona-xtrabackup-2.4.26.zip    
https://docs.percona.com/percona-xtrabackup/2.4/installation/compiling_xtrabackup.html   

### centos7
阿里云上的新加坡区centos7 arm, 各种安装不上
gcc升级: https://gist.github.com/tyleransom/2c96f53a828831567218eeb7edc2b1e7, 也升级不上

```text
echo "Downloading gcc source files..."
curl https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.bz2 -O

echo "extracting files..."
tar xvfj gcc-5.4.0.tar.bz2

echo "Installing dependencies..."
yum install gmp-devel mpfr-devel libmpc-devel

echo "Configure and install..."
mkdir gcc-5.4.0-build
cd gcc-5.4.0-build
../gcc-5.4.0/configure --enable-languages=c,c++ --disable-multilib
make -j$(nproc) && make install # note: nproc is the number of threads (e.g. 4 or 8
```

### ubuntu
- 要用ubuntu18: Ubuntu 18.04.5 LTS, cpu搞大些
```text
cat /etc/os-release
NAME="Ubuntu"
VERSION="18.04.5 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.5 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic
```
- arch命令输出: aarch64
  cmake -DWITH_BOOST=PATH-TO-BOOST-LIBRARY -DDOWNLOAD_BOOST=ON \
  -DBUILD_CONFIG=xtrabackup_release -DWITH_MAN_PAGES=OFF -B ..
- 安装依赖
```text
apt install build-essential flex bison automake autoconf \
libtool cmake libaio-dev mysql-client libncurses-dev zlib1g-dev \
libgcrypt11-dev libev-dev libcurl4-gnutls-dev vim-common
```
- gcc版本
```text
 gcc --version
gcc (Ubuntu/Linaro 7.5.0-3ubuntu1~18.04) 7.5.0
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```
- mkdir build && cd build
- 编译
```text
cmake -DWITH_BOOST=PATH-TO-BOOST-LIBRARY -DDOWNLOAD_BOOST=ON \
-DBUILD_CONFIG=xtrabackup_release -DWITH_MAN_PAGES=OFF -B ..
```
- cmake报错
```text
-- Downloading boost_1_59_0.tar.gz to /root/percona-xtrabackup-percona-xtrabackup-2.4.26/build/PATH-TO-BOOST-LIBRARY -- Download failed, error: 7;"Couldn't connect to server" CMake Error at cmake/boost.cmake:201 (MESSAGE): You can try downloading http://jenkins.percona.com/downloads/boost/boost_1_59_0.tar.gz manually using curl/wget or a similar tool Call Stack (most recent call first): CMakeLists.txt:551 (INCLUDE)
```
- boost_1_59_0.tar.gz
http://jenkins.percona.com/downloads/boost/boost_1_59_0.tar.gz 不可用  
wget https://boostorg.jfrog.io/artifactory/main/release/1.59.0/source/boost_1_59_0.tar.gz, 下载在了 /root/boost/boost_1_59_0.tar.gz, 也不行
wget https://archives.boost.io/release/1.59.0/source/boost_1_59_0.tar.gz  下载在了 /root/boost/boost_1_59_0.tar.gz
```text
  md5sum boost_1_59_0.tar.gz
  51528a0e3b33d9e10aaa311d9eb451e3  boost_1_59_0.tar.gz
```
- 更改cmake指令
```text
cd percona-xtrabackup-percona-xtrabackup-2.4.26/build/

cmake \
  -DWITH_BOOST=/root/boost \
  -DDOWNLOAD_BOOST=OFF \
  -DBUILD_CONFIG=xtrabackup_release \
  -DWITH_MAN_PAGES=OFF \
  -B ..
```
- 好像缺乏ssl
```text
Cannot find appropriate system libraries for WITH_SSL=system.
Make sure you have specified a supported SSL version.
Valid options are :
system (use the OS openssl library),
yes (synonym for system),
</path/to/custom/openssl/installation>

CMake Error at cmake/ssl.cmake:63 (MESSAGE):
  Please install the appropriate openssl developer package.

Call Stack (most recent call first):
  cmake/ssl.cmake:279 (FATAL_SSL_NOT_FOUND_ERROR)
  CMakeLists.txt:583 (MYSQL_CHECK_SSL)
```
- 安装openssl相关
apt-get install -y libssl-dev
- 重复"更改cmake指令"这一步
没有报错
- make
还是在build目录
- make install
还是在build目录, 执行, 默认安装在/usr/local/xtrabackup
### 总结
- 下载源码
wget -O /root/percona-xtrabackup-2.4.26.zip https://github.com/percona/percona-xtrabackup/archive/refs/tags/percona-xtrabackup-2.4.26.zip  
cd /root && unzip percona-xtrabackup-2.4.26.zip  
cd percona-xtrabackup-percona-xtrabackup-2.4.26 && mkdir build && cd build
- apt安装
```text
apt install build-essential flex bison automake autoconf \
libtool cmake libaio-dev mysql-client libncurses-dev zlib1g-dev \
libgcrypt11-dev libev-dev libcurl4-gnutls-dev vim-common  libssl-dev
```
- download boost_1_59_0.tar.gz
mkdir ~/boost && wget -P ~/boost https://archives.boost.io/release/1.59.0/source/boost_1_59_0.tar.gz 
- cmake
```text
cd percona-xtrabackup-percona-xtrabackup-2.4.26/build/

cmake \
  -DWITH_BOOST=/root/boost \
  -DDOWNLOAD_BOOST=OFF \
  -DBUILD_CONFIG=xtrabackup_release \
  -DWITH_MAN_PAGES=OFF \
  -B ..
```
- make
- make install 