# Test Plan

## Introduction

This document outlines a basic test plan for verifying UMD customizations
to stock ArchivesSpace functionality.

The intention is to provide basic assurance that the UMD customizations are
functional, and guard against regressions.

**This document is not intended to be an exhaustive test plan, nor should it
replace stakeholder testing.**

## Testing Resources

UMD customizations are provided in the form of ArchivesSpace plugins, each in
its own GitHub repository. Each plugin provides its own verification steps
for testing.

The following is a suggested order for verifying the plugin functionality:

1) [umd-lib/umd-lib-aspace-theme/docs/PublicInterfaceCustomizations.md][1]

2) [umd-lib/umd-lib-aspace-theme/docs/StaffInterfaceCustomizations.md][2]

3) [umd-lib/aspace-custom/docs/Customizations.md][3]

4) [umd-lib/aspace_yale_accessions/docs/Customizations.md][4]

5) [umd-lib/aspace-umd-lib-handle-service/README.md][5]

6) [umd-lib/umd_aeon_fulfillment/docs/Customizations.md][6]

---

[1]: https://github.com/umd-lib/umd-lib-aspace-theme/blob/main/docs/PublicInterfaceCustomizations.md
[2]: https://github.com/umd-lib/umd-lib-aspace-theme/blob/main/docs/StaffInterfaceCustomizations.md
[3]: https://github.com/umd-lib/aspace-custom/blob/main/docs/Customizations.md
[4]: https://github.com/umd-lib/aspace_yale_accessions/blob/main/docs/Customizations.md
[5]: https://github.com/umd-lib/aspace-umd-lib-handle-service/blob/main/README.md
[6]: https://github.com/umd-lib/umd_aeon_fulfillment/blob/main/docs/Customizations.md
