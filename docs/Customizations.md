# Customizations

## Introduction

This documents describes the customizations to the stock ArchivesSpace
application provided by this repository.

See [docker_config/archivesspace/config/plugins][plugins]" for version
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
