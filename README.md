# aspace-custom

UMD customizations to the stock ArchvesSpace
([https://archivesspace.org/](https://archivesspace.org/))
application, and provides Dockerfiles for creating the Docker images used by the
[umd-lib/k8s-aspace](https://github.com/umd-lib/k8s-aspace) Kubernetes
configuration.

This repository is intended to replace:

* [umd-lib/aspace-docker](https://github.com/umd-lib/aspace-docker)
* [https://bitbucket.org/umd-lib/aspace-env](https://bitbucket.org/umd-lib/aspace-env)

## Development Setup

See [docs/DevelopmentSetup.md](docs/DevelopmentSetup.md).

## Dockerfiles

* Dockerfile - The Dockerfile for creating the UMD-customized ArchivesSpace
Docker image
* Dockerfile-solr - The Dockerfile for creating the Solr instance to use with
  ArchivesSpace
* Dockerfile-api-proxy - The Dockerfile for creating an Nginx reverse proxy for
protecting the ArchivesSpace API from anonymous access.

## Docker Image Creation for Release

The following steps use the Kubernetes "build" namespace to build the Docker
images. This enables the steps to used with both newer Apple Silicon laptops and
older Intel-based Apple laptops.

For information about setting up the Kubernetes "build" namespace, see
the "Docker Builds" document in the "umd-lib/devops" GitHub repository:

<https://github.com/umd-lib/devops/blob/main/k8s/docs/DockerBuilds.md>

1) Switch to the Kubernetes "build" namespace:

    ```bash
    $ kubectl config use-context build
    ```

2) Build the Docker images, where \<TAG> is the Docker image tag to use:

    ```bash
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace:<TAG> -f Dockerfile .
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace-api-proxy:<TAG> -f Dockerfile-api-proxy .
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace-solr:<TAG> -f Dockerfile-solr .
    ```

    For example, to build all the images using "latest" as the image tag:

    ```bash
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace:latest -f Dockerfile .
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace-api-proxy:latest -f Dockerfile-api-proxy .
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/aspace-solr:latest -f Dockerfile-solr .
    ```

    The images will be automatically pushed to the Nexus.

## Directories

### docker_config/archivesspace/

Files/directories used to configure the ArchivesSpace Docker image.

#### docker_config/archivesspace/archivesspace

The files in this directory are directly copied (overlaid) on top of a
stock ArchivesSpace distribution.

#### docker_config/archivesspace/files/

The files in this directory are plugin-related files that are copied in to an
ArchivesSpace distribution by the "scripts/plugins.sh" script.

The files cannot be placed in the "archivesspace" directory, because the
required plugin directories don't exist until the "plugins.sh" script creates
them,

#### docker_config/archivesspace/config/

Holds the "plugins" files specifying the ArchivesSpace plugins used by the
UMD version of ArchivesSpace.

#### docker_config/archivesspace/scripts/

Holds the "plugins.sh" script for downloading and installing the ArchivesSpace
plugins specified in the "archivesspace/config/config.rb" file.

### docker_config/solr/

Files/directories used to configure the ArchivesSpace Solr Docker image.

### docker_config/api-proxy/

Contains the Nginx configuration file for reverse proxy that protects the
ArchivesSpace API endpoints from anonymous access.
