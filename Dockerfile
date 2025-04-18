# Use the official PostgreSQL latest image as a base
FROM postgres:latest

# 动态创建并替换阿里云镜像源
RUN DEBIAN_VERSION=$(awk -F'=' '/VERSION_CODENAME/ {print $2}' /etc/os-release) \
    && echo "deb http://mirrors.aliyun.com/debian/ ${DEBIAN_VERSION} main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian-security ${DEBIAN_VERSION}-security main" >> /etc/apt/sources.list \
    && apt-get update

# Install necessary packages and clone the pgvector repository
RUN apt-get update && \
    apt-get install -y \
        postgresql-server-dev-17 \
        build-essential \
        git
ENV PATH="/usr/lib/postgresql/17/bin:${PATH}"
RUN git clone https://github.com/pgvector/pgvector.git

# 明确指定pg_config路径


# Build and install the pgvector extension
RUN cd pgvector && \
    make && \
    make install

# Clean up
RUN apt-get remove --purge -y \
        build-essential \
        git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /pgvector

# Set the default command to run when starting the container
CMD ["postgres"]

