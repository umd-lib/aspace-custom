# Environment Variables

## Introduction

An overview of the environment variables used to configure properties in the
"docker_config/archivesspace/archivesspace/config/config.rb" file.

## Aeon Requests

* DISABLE_AEON_REQUEST - Set to "true" to the disable Aeon request functionality
  (by removing the aeon_fulfillment/umd_aeon_fulfillment plugins from the plugin
  list).

  Any other value enables Aeon requests.

## Database

* ASPACE_DB_URL - A JDBC URL that configures the connection to the database.

## Logging Levels

Logging level settings for individual ArchivesSpace components.

After making a change and applying in Kubernetes, the "aspace-app" container
will need to be restarted before the change takes affect.

Valid values (from the [ArchivesSpace documentation][docs-logging]) are
`debug`, `info`, `warn`, `error`, `fatal`.

* BACKEND_LOG_LEVEL
* FRONTEND_LOG_LEVEL
* INDEXER_LOG_LEVEL
* PUI_LOG_LEVEL

## Matomo Analytics

* MATOMO_ANALYTICS_URL - the URL to send activity to
* MATOMO_ANALYTICS_SITE_ID - the site id to send activity for

## Proxy URLs

* PUBLIC_INTERFACE_PROXY_URL - the user-facing URL for the public interface,
  i.e., `https://archives.lib.umd.edu/`
* STAFF_INTERFACE_PROXY_URL - the user-facing URL for the staff interface,
  i.e., `https://aspace.lib.umd.edu/`

## Server

* SERVER_NAME - the Kubernetes service name for the ArchivesSpace application,
  i.e., `aspace-app`

## Solr

* ASPACE_SOLR_URL - the Kubernetes service-based URL for communicating with
  the ArchivesSpace Solr instance, i.e.,
  `http://aspace-solr:8983/solr/archivesspace`

## Umd Handle Server

* UMD_HANDLE_JWT_TOKEN - the JWT token for authenticating to the UMD Handle
  server. **Note:** This value should a Kubernetes secret.
* UMD_HANDLE_SERVER_URL - the Kubernetes service-based URL for communicating
  with the UMD Handle server, i.e., `http://umd-handle-app:3000/api/v1/handles`

---
[docs-logging]: https://docs.archivesspace.org/customization/configuration/#application-logging
