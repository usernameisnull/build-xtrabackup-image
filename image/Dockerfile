# 使用指定的基础镜像
FROM centos:8.3.2011
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum makecache && \
    yum install -y libaio && \
    yum clean all && \
    rm -rf /var/cache/yum
# 设置工作目录（可选）
WORKDIR /tmp

# 拷贝 xtrabackup 压缩包到容器中, 这个是从ubuntu18里编译后拷贝过来的
COPY xtrabackup-2.4.26-aarch64.tar.gz .

# 解压到 /usr/local 并清理临时文件
RUN tar -xzf xtrabackup-2.4.26-aarch64.tar.gz -C /usr/local && \
    rm -f xtrabackup-2.4.26-aarch64.tar.gz

# 将 xtrabackup 的 bin 目录加入 PATH
ENV PATH="/usr/local/xtrabackup/bin:${PATH}"

# 可选：验证安装（构建时可注释掉）
# RUN xtrabackup --version