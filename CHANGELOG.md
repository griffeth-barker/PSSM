# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Add feature to harden service executable paths
- Add feature to harden service executable permissions
- Add feature to connect to remote computers
- Fix startup performance
- Pester tests

## [0.1.1] - 2026-01-04
This is largely a cosmetic release, however the application icon was changed which resulted in a re-wrap of the application and a new SHA256 hash as shown below.

### Added

- Additional documentation
  - [Development](/docs/development.md)
  - [Features](/docs/features.md)
  - [User Guide](/docs/userguide.md)
- New application icon
- Screenshots

SHA256: `0EA70718B7AC7A056454FD136E2E67BFD0A72EF16F1876C1A66883C45EEF25B8`

## [0.1.0] - 2026-01-03

### Added

- [pssm.ps1](./src/pssm.ps1) main script
- [build.ps1](./build/build.ps1) build script
- Populate initial [docs](/docs)
- v0.1.0 executable
  - Display service summary in main grid view
  - Display service details in modal from context menu
  - Display whether service executable path is hardened in main grid view and details modal
  - Display whether service executable permissions are overly permissive in main grid view and details modal
  - Display service uptime in main grid view
  - Open service executable's parent directory from context menu
  - Open service executable's key in the registry from context menu
  - Install a new service
  - Delete an existing service

SHA256: `33791DA9885254D80E1467AF43C29FF626F0B9AE63207F58C2728DACE994F696`

[unreleased]:
[0.1.1]: https://github.com/griffeth-barker/PSSM/tree/v0.1.1
[0.1.0]: https://github.com/griffeth-barker/PSSM/tree/v0.1.0