# Dockerfile for generating the ArchivesSpace application Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/aspace:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.

# This Dockerfile uses the same base image as the ArchivesSpace Dockerfile from
#
# https://github.com/archivesspace/archivesspace/blob/v4.1.1/Dockerfile
#
# but is significantly customized to support UMD's setup, including:
#
# * Use of the "/apps/aspace/archivesspace" directory, instead of the
#   "/archivesspace" directory -- additional UMD configuration/plugin files are
#   placed in the "/apps/aspace" directory
#
# * Using "aspace" as the user in the container, instead of "archivesspace"
#
# * the number of ports available via EXPOSE is limited to the backend,
#   frontend, and public interfaces.
#
# * the CMD used by the Dockerfile has been customized, so that the
#   "docker-startup.sh" script is run
FROM ubuntu:22.04

ENV ARCHIVESSPACE_LOGS=/dev/null \
  ASPACE_GC_OPTS="-XX:+UseG1GC -XX:NewRatio=1" \
  DEBIAN_FRONTEND=noninteractive \
  JDK_JAVA_OPTIONS="--add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED" \
  LANG=C.UTF-8 \
  TZ=UTC

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      ca-certificates \
      git \
      libjemalloc-dev \
      openjdk-17-jre-headless \
      netbase \
      shared-mime-info \
      wget \
      nodejs \
      unzip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /apps/aspace && \
    cd /apps/aspace && \
    wget https://github.com/archivesspace/archivesspace/releases/download/v4.1.1/archivesspace-v4.1.1.zip -O archivesspace.zip && \
    unzip archivesspace.zip && \
    cd /apps/aspace/archivesspace && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.30/mysql-connector-java-8.0.30.jar -O mysql-connector-java-8.0.30.jar && \
    mv mysql-connector-java-8.0.30.jar lib/

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

# Add the "aspace" user (UID/GID 1000)
# Note: Kubernetes assumes the "aspace" user is UID/GID 1000 for file permissions
RUN groupadd -g 1000 aspace && \
    useradd -l -m -u 1000 -g aspace aspace && \
    chown -R aspace:aspace /apps/aspace

USER aspace

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

RUN cd /apps/aspace && \
    chmod u+x archivesspace/docker-startup.sh && \
    scripts/plugins.sh

# See archivesspace/config/config.rb for list of ports to export
EXPOSE 8080 8081 8083

# docker-startup script includes running /apps/aspace/archivesspace/scripts/setup-database.sh
CMD ["/apps/aspace/archivesspace/docker-startup.sh"]
