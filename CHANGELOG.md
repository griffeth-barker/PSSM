# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Add feature to harden service executable paths
- Add feature to harden service executable permissions
- Add feature to connect to remote computers
- Fix startup performance

## [0.1.0] - 2026-01-04

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
[0.1.0]: 