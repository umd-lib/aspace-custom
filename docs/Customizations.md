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

### hudmol/and_search

<https://github.com/hudmol/and_search.git>

### hudmol/default_text_for_notes

<https://github.com/hudmol/default_text_for_notes.git>

### hudmol/digitization_work_order

<https://github.com/hudmol/digitization_work_order.git>

### hudmol/payments_module

<https://github.com/hudmol/payments_module.git>

Tried to update this plugin to v1.5, but ran into the following database
migration issue when starting the application in the Kubernetes “sandbox”:

```text
aspace-app-0 aspace I, [2024-09-20T17:05:11.783742 #12]  INFO -- : Begin applying migration version 7, direction: up
aspace-app-0 aspace E, [2024-09-20T17:05:11.807444 #12] ERROR -- : Java::ComMysqlJdbcExceptionsJdbc4::MySQLIntegrityConstraintViolationException: Duplicate entry 'payments_module_cost_center' for key 'name': INSERT INTO `enumeration` (`name`, `json_schema_version`, `editable`, `create_time`, `system_mtime`, `user_mtime`) VALUES ('payments_module_cost_center', 1, 1, '2024-09-20 17:05:11', '2024-09-20 17:05:11', '2024-09-20 17:05:11')
```

Set the “hudmol/payments_module” to use version "20190624”, which is the
tagged version of the “5fddd44caf2002ba34578e1eead7fb9efb83cdee” commit hash
that was previously being used.

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

---
[plugins]: ../docker_config/archivesspace/config/plugins
[hudmol-accessions]: https://github.com/hudmol/aspace_yale_accessions
[atlas-aeon]: https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin
