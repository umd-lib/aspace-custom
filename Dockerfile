# Dockerfile for generating the ArchivesSpace application Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/aspace:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.

# This Dockerfile is largely taken from
# https://github.com/archivesspace/archivesspace/blob/v3.1.0/Dockerfile
# and https://github.com/dartmouth-dltg/aspace-docker
FROM eclipse-temurin:8u462-b08-jre

ENV LANG=C.UTF-8


RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y install --no-install-recommends \
      git \
      wget \
      unzip && \
      rm -rf /var/lib/apt/lists/*

RUN mkdir -p /apps/aspace && \
    cd /apps/aspace && \
    wget https://github.com/archivesspace/archivesspace/releases/download/v3.5.1/archivesspace-v3.5.1.zip -O archivesspace.zip && \
    unzip archivesspace.zip && \
    cd /apps/aspace/archivesspace && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar -O mysql-connector-java-5.1.39.jar && \
    mv mysql-connector-java-5.1.39.jar lib/

# Copy in archivesspace customizations from the "archivesspace" directory
COPY docker_config/archivesspace/archivesspace/ /apps/aspace/archivesspace

# Copy plugins customizations
COPY docker_config/archivesspace/files /apps/aspace/files

# Copy config files to
COPY docker_config/archivesspace/config /apps/aspace/config

# Copy plugins customizations
COPY docker_config/archivesspace/scripts /apps/aspace/scripts

# # Copy Solr files into /apps/aspace/archivesspace/solr, for Solr checksum verification
COPY docker_config/solr/conf /apps/aspace/archivesspace/solr

# Rename the default "ubuntu" user (UID/GID 1000) to "aspace"
# Note: Kubernetes assumes the "aspace" user is UID/GID 1000 for file permissions
RUN usermod -l aspace -d /home/aspace -m ubuntu && \
    groupmod -n aspace ubuntu && \
    usermod -c "" aspace

USER aspace

RUN cd /apps/aspace && \
    chmod u+x archivesspace/docker-startup.sh && \
    scripts/plugins.sh

# See archivesspace/config/config.rb for list of ports to export
EXPOSE 8080 8081 8083

# docker-startup script includes running /apps/aspace/archivesspace/scripts/setup-database.sh
CMD ["/apps/aspace/archivesspace/docker-startup.sh"]
