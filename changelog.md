# Changelog

All notable changes to DCS-MYTHS-CTLD will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-01-06

### Added
- Added PowerShell build system for modular Lua development
- Created build script (`build.ps1`) for splitting and compiling Lua files
- Added C130j test mission for airdrop functionality testing

### Fixed
- Fixed Dynmaic Spawn issue
- Fixed JTAC export/build issues
- Cleaned up configuration files for better maintainability:
  - Optimized `config.lua` structure
  - Improved `infantry_config.lua` formatting
  - Streamlined `spawn_config.lua` settings
  - Enhanced `transport_config.lua` organization
  - Refined `unit_config.lua` configuration
  - Updated `zones_config.lua` structure

### Changed
- Restructured project file organization:
  - Moved audio assets to `assets/` directory
  - Moved vendor dependencies to `vendor/` directory
  - Organized sample missions in `sample-missions/` directory
  - Split main Lua code into modular files in `import/` directory
- Renamed `CTLD_rebuilt.lua` to `CTLD_compiled.lua` for clarity
- Updated build process to use new modular structure

### Technical
- Implemented Lua code modularization system
- Added export registry system for build order management
- Enhanced build toolchain with PowerShell scripting

## Previous Releases

### [1.6.1] - ASC C-130
- Initial C-130 airdrop functionality development

### [1.6.0-alpha] - Testing Release
- Alpha version for testing new features
- Multiple fixes and enhancements by Fullgas
- FOB airdropping fixes
