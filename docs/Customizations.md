# Customizations

## Introduction

This documents describes the customizations to the stock ArchivesSpace
application provided by this repository.

See "[docker_config/archivesspace/config/plugins][plugins]" for version
information on individual plugins.

## ArchivesSpace Plugins

The following plugins are stock plugins provided by the community, which have
not been modified by SSDR:

### AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin

<https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin>

**Note**: This plugin is itself customized by the "umd-lib/umd_aeon_fulfillment"
plugin.

### hudmol/default_text_for_notes

<https://github.com/hudmol/default_text_for_notes.git>

### hudmol/digitization_work_order

<https://github.com/hudmol/digitization_work_order.git>

### lyrasis/aspace-oauth

<https://github.com/lyrasis/aspace-oauth.git>

## UMD Customized Plugins

The following plugins have been customized by SSDR, and contain their own
"Customizations.md" document.

### umd-lib/aspace-umd-lib-handle

<https://github.com/umd-lib/aspace-umd-lib-handle-service>

Mints UMD handles on creation of new Resource records in ArchivesSpace.

### umd-lib/aspace_yale_accessions

<https://github.com/umd-lib/aspace_yale_accessions.git>

UMD customizations to the [hudmol/aspace_yale_accessions][hudmol-accessions]
plugin.

### umd-lib/umd-lib-aspace-theme

<https://github.com/umd-lib/umd-lib-aspace-theme>

Provides UMD branding and other GUI customizations to the ArchivesSpace
"front-end" and "public" interfaces.

### umd-lib/umd_aeon_fulfillment

<https://github.com/umd-lib/umd_aeon_fulfillment.git>

UMD customizations to the
[AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin][atlas-aeon]
plugin.

## Removed Plugins

The following plugins were previously part of the UMD ArchivesSpace
configuration, but have since been removed.

### hudmol/and_search

<https://github.com/hudmol/and_search.git>

Removed as part of the ArchivesSpace 4.1.1 upgrade, as ArchivesSpace now uses
the AND operator for Solr searches by default. See
[ANW-427](https://archivesspace.atlassian.net/browse/ANW-427).

### hudmol/payments_module

<https://github.com/hudmol/payments_module.git>

Removed as part of the ArchivesSpace 4.1.1 upgrade, as the functionality of the
plugin is not used, and not needed.

In ArchivesSpace 3.5.1, tried to update this plugin to v1.5, but ran into the
following database migration issue when starting the application in the
Kubernetes “sandbox”:

```text
aspace-app-0 aspace I, [2024-09-20T17:05:11.783742 #12]  INFO -- : Begin applying migration version 7, direction: up
aspace-app-0 aspace E, [2024-09-20T17:05:11.807444 #12] ERROR -- : Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry 'payments_module_cost_center' for key 'name': INSERT INTO `enumeration` (`name`, `json_schema_version`, `editable`, `create_time`, `system_mtime`, `user_mtime`) VALUES ('payments_module_cost_center', 1, 1, '2024-09-20 17:05:11', '2024-09-20 17:05:11', '2024-09-20 17:05:11')
```

Set the version to "20190624”, which is the tagged version of the
“5fddd44caf2002ba34578e1eead7fb9efb83cdee” commit hash that was previously being
used.

In ArchivesSpace 4.1.1, the plugin (still using the "20190624” version) was
removed from the configuration. The database tables added by the plugin were
*not* removed as it seemed harmless to leave them in place, and removing them
could potentially cause unknown side effects.

## Verification Steps

The UMD-customized plugins should provide verification steps within the
UMD GitHub repository that manages the plugin.

In this section, basic verification steps for plugins and other significant
ArchivesSpace functionality that are used "AS-IS" without a separate UMD GitHub
repository are outlined.

**These steps are not intended to be an exhaustive test plan.**

### Verification Steps - REST API endpoint

The REST API enables clients such as
[ArchivesSnake](https://github.com/archivesspace-labs/ArchivesSnake) to
interact with ArchivesSpace via its API.

The following steps assume that your ArchivesSpace account is configured with a
password so that you can log in using the "Sign In" link on the ArchivesSpace
staff interface home page, as opposed to signing in via the "UMD Log-In" link.
You should also be either on-campus, or connected to the campus VPN.

1) Set the base URL of the REST API endpoint. The following example uses the
ArchivesSpace running in the Kubernetes "test" namespace:

    ```bash
    $ export API_BASE_URL=https://archives-api-test.lib.umd.edu
    ```

2) Run the following command:

    ```bash
    $ curl $API_BASE_URL/ping
    ```

    Verify that the response is:

    ```html
    <!DOCTYPE html><h2>api-proxy OK</h2></html>
    ```

3) Run the following command:

    ```bash
    $ curl $API_BASE_URL/
    ```

    A "403 Forbidden" response should be returned.

4) Run the following command (to attempt to access the ArchivesSpace API
"version" endpoint":

    ```bash
    $ curl $API_BASE_URL/version
    ```

    A "403 Forbidden" response should be returned.

5) Log in to the ArchivesSpace API using the following command:

    ```bash
    $ curl -s -F password="<PASSWORD>" $API_BASE_URL/users/<USERNAME>/login
    ```

    where \<PASSWORD> and \<USERNAME> are your ArchivesSpace account credentials
    (which are different from your UMD CAS login credentials). For example if
    your username is "jsmith" and your password is "secret", the command would
    be:

    ```bash
    curl -s -F password="secret" $API_BASE_URL/users/jsmith/login
    ```

    This should return a JSON reponse that looks like:

    ```json
    {"session":"d00a08fd5229f7b4789438079a9316192ca792a75c39def32cdba791faf06ff8","user":{ ...
    ```

    Note the "session" value.

6) Run the following command:

    ```bash
    $ export SESSION=<SESSION_ID>
    ```

    where <SESSION_ID> is the session id from the previous step. For example:

    ```bash
    $ export SESSION=d00a08fd5229f7b4789438079a9316192ca792a75c39def32cdba791faf06ff8
    ```

7) Run the following command:

    ```bash
    $ curl -H "X-ArchivesSpace-Session: $SESSION" $API_BASE_URL/version
    ```

    and verify that the ArchivesSpace version, such as the following is
    returned:

    ```text
    ArchivesSpace (v4.1.1)
    ```

8) Create a "bad" session id:

    ```bash
    $ export BAD_SESSION=ABCD
    ```

    and then run the command:

    ```bash
    $ curl -H "X-ArchivesSpace-Session: $BAD_SESSION" $API_BASE_URL/version
    ```

    and verify that the following message is returned:

    ```json
    {"code":"SESSION_GONE","error":"No session found for ABCD"}
    ```

### Verification Steps - OAI-PMH endpoint

The OAI-PMH endpoint is stock ArchivesSpace functionality
that enables OAI-PHM clients to interact with ArchivesSpace.

The OAI-PMH interface is accessible at the "/oai" path on the public interface,
i.e. for the ArchivesSpace test server:

<https://archives-api-test.lib.umd.edu/oai?verb=Identify>

This should return an XML response similar to the following:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
  <responseDate>2026-02-11T14:32:19Z</responseDate>
  <request verb="Identify">https://archives-api-test.lib.umd.edu/oai</request>
  <Identify>
    <repositoryName>ArchivesSpace OAI Provider</repositoryName>
    <baseURL>https://archives-api-test.lib.umd.edu/oai</baseURL>
    <protocolVersion>2.0</protocolVersion>
    <adminEmail>admin@example.com</adminEmail>
    <earliestDatestamp>1970-01-01T00:00:00Z</earliestDatestamp>
    <deletedRecord>persistent</deletedRecord>
    <granularity>YYYY-MM-DDThh:mm:ssZ</granularity>
    <description>
      <oai-identifier xmlns="http://www.openarchives.org/OAI/2.0/oai-identifier" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai-identifier http://www.openarchives.org/OAI/2.0/oai-identifier.xsd">
        <scheme>oai</scheme>
        <repositoryIdentifier>archivesspace</repositoryIdentifier>
        <delimiter>:</delimiter>
        <sampleIdentifier>oai:archivesspace//repositories/2/resources/1</sampleIdentifier>
      </oai-identifier>
    </description>
  </Identify>
</OAI-PMH>
```

The `<request verb="Identify">` and `<baseURL>` elements should reference the
REST API URL:

* sandbox: `https://archives-api.sandbox.lib.umd.edu/oai`
* test:  `https://archives-api-test.lib.umd.edu/oai`
* qa: `https://archives-api-qa.lib.umd.edu/oai`
* prod: `https://archives-api.lib.umd.edu/oai`

### Verification Steps - lyrasis/aspace-oauth

**Note:** The following steps assume that you have an active user account
in ArchivesSpace.

On the ArchivesSpace staff interface home page, verify that there is a
"UMD Log-In" in the upper-right corner of the page.

After left-clicking the link, verify that you are redirected to CAS, and
after successfully authenticating, that you are logged in to ArchivesSpace.

### Verification Steps - hudmol/default_text_for_notes

In the ArchivesSpace staff interface, create a new accession
(Create | Accession from the application menubar). Verify that in the resulting
"New Accession" form:

* The "Basic Information - Access Restrictions Note" field has the default text
from "docker_config/archivesspace/files/accession_access_restrictions_note.txt"
file, i.e.:

  > This collection is open to the public and ...

* The "Basic Information - Use Restrictions Note" field has the default text
from "docker_config/archivesspace/files/accession_access_restrictions_note.txt"
file, i.e.:

  > Photocopies or digital surrogates may be ...

### Verification Steps - hudmol/digitization_work_order

1) Log in to the ArchivesSpace staff interface.

2) Browse the resources (Browse | Resources from the application menubar), and
left-click the "View" button for one of the resources.

3) In the menubar at the top of the resource, left-click the "More" drop-down,
when left-click "Work Order Report". The "Work Order Form" page will be
displayed.

---
[plugins]: ../docker_config/archivesspace/config/plugins
[hudmol-accessions]: https://github.com/hudmol/aspace_yale_accessions
[atlas-aeon]: https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin
