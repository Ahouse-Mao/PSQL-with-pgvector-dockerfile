# Use the official PostgreSQL latest image as a base
FROM postgres:latest

# Change the apt source to Aliyun
RUN DEBIAN_VERSION=$(awk -F'=' '/VERSION_CODENAME/ {print $2}' /etc/os-release) \
    && echo "deb http://mirrors.aliyun.com/debian/ ${DEBIAN_VERSION} main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian-security ${DEBIAN_VERSION}-security main" >> /etc/apt/sources.list 

# Install mawk and build dependencies for pgvector
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y mawk && \
    PSQL_VERSION=$(psql --version | awk '{print $3}' | cut -d'.' -f1) && \
    echo "export PSQL_MAJOR_VERSION=$PSQL_VERSION" >> /root/.bashrc && \
    apt-get install -y \
        postgresql-server-dev-${PSQL_VERSION} \
        build-essential \
        git

# Build and install the pgvector extension

RUN git clone https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make && \
    make install

# Clean up
RUN apt-get remove --purge -y \
        build-essential \
        mawk \
        git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /pgvector

# Set the default command to run when starting the container
CMD ["postgres"]

