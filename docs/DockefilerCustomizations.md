# Dockerfile Customizations

## Introduction

ArchivesSpace provides a number of stock Dockerfiles for running the application
in a Docker Compose stack:

* Dockerfile - builds ArchivesSpace from source, and runs the resulting
  application, using a multistage Docker build
* solr/Dockerfile - the Solr instance to run alongside ArchivesSpace
* proxy/Dockerfile - routes particular endpoints (`/`, `/staff`, `/oai`,
  `/staff/api`) to the public interface, staff interface, OAI-PMH interface,
  and API interface.

This repository does not use these stock Dockerfiles directly because they do
not provide a simple mechanism for overlaying/overriding ArchivesSpace
functionality with UMD customizations. They are also not specifically geared
for Kubernetes (for example, the "proxy/Dockerfile" is not needed).

## docker.lib.umd.edu/aspace

### Dockerfile

The "Dockerfile" file creates the "docker.lib.umd.edu/aspace" Docker image which
provides the UMD-customized ArchivesSpace application. While the stock
ArchivesSpace "Dockerfile" (in the "archivesspace/archivesspace" GitHub
repository) provides inspiration/guidance for this file, it is not
used because it does not provide a simple mechanism for installing plugins,
or overlaying/overriding ArchivesSpace functionality with UMD customizations.

The differences with the stock ArchivesSpace Docker image are:

* Instead of a multistage Docker build, where ArchivesSpace is built from source
  and placed into a "/archivesspace" directory, a Zip file containing the
  ArchivesSpace build is downloaded from ArchivesSpace, and extracted into the
  "/apps/aspace/archivesspace" directory.
* an "aspace" user is used, instead of "archivesspace"
* The "/apps/aspace" directory in the Docker container contains subdirectories
  ("config", "files", "scripts") that are used to modify the stock ArchivesSpace
  from the Zip file.
* Some files are directly overlaid onto the unzipped ArchivesSpace in
  /apps/aspace/archivesspace (overwriting files from the stock ArchivesSpace).

### docker_config/archivesspace

The following subdirectories are used to modify the stock ArchivesSpace in
/apps/aspace/archivesspace:

* docker_config/archivesspace/archivespace - Overwrite existing stock
  ArchivesSpace configuration files
* docker_config/archivesspace/config - Contains the "plugins" file used to
  install the UMD set of ArchivesSpace plugins (via the
  "docker_config/archivesspace/scripts/plugins.sh" script).
* docker_config/archivesspace/files - Plugin-related configuration files that
  are added by the "docker_config/archivesspace/scripts/plugins.sh" script after
  the plugins are installed. These files must be installed after the plugins,
  because the destination directories for the files do not exist until plugins
  are installed.
* docker_config/archivesspace/scripts - Contains the "plugins.sh" that downloads
  the plugins and configures the plugins, using the
  "docker_config/archivesspace/config/plugins" file, and configuration files
  from the "docker_config/archivesspace/files" directory.

## Dockerfile-solr

The "Dockerfile-solr" file creates the "docker.lib.umd.edu/aspace-solr" Docker
image which the Solr instance used by ArchivesSpace.

The "Dockerfile-solr" file is a copy of the "solr/Dockerfile" from the
"archivesspace/archivespace" GitHub repository, with only minor modifications:

* A header comment providing information about the file
* The "COPY" command has been changed to copy files from the
  "docker_config/solr/conf/" directory.

While it is possible to generate the "docker.lib.umd.edu/aspace-solr" Docker
image from the "archivesspace/archivespace" GitHub repository, it seemed more
convenient to include them in this repository, so that all the Dockerfiles
needed to construct the UMD version of ArchivesSpace were in one repository.

### docker_config/solr/conf/

The configuration files copied into the Solr Docker image. The files in this
directory are an exact copy of their counterparts in the "solr" directory of
the "archivesspace/archivespace" GitHub repository.

The following files were not included, because they seemed unnecessary:

* solr/delete.sh
* solr/Dockerfile - equivalent to "Dockerfile-solr"
* solr/.dockerignore

## Dockerfile-api-proxy

The "Dockerfile-api-proxy" file creates the
"docker.lib.umd.edu/aspace-api-proxy" Docker image which provides an Nginx
reverse proxy for securing the ArchiveSpace API endpoint.

It is *not* related to the "proxy/Dockerfile" in the
"archivesspace/archivespace" GitHub repository (the functionality of which is
handled by Kubernetes Ingress objects). Instead it secures the ArchivesSpace
API endpoint against anonymous access (see LIBASPACE-289).

### docker_config/api-proxy

Contains the "nginx.conf" file used to configure the Nginx proxy for the
ArchivesSpace API endpoint. It has not direct counterpart in stock
ArchivesSpace.
