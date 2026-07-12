# Changelog

All notable changes to this project will be documented in this file.

From the next release onwards this file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions. Older entries below are preserved as originally written.

## [Unreleased]

### Changed

- Relaxed the Dart SDK lower bound from the pre-release `3.1.0-331.0.dev` to the stable `3.1.0`, so the package resolves without requiring a pre-release SDK.

### Fixed

- `Security1.securitySession` now returns `null` instead of throwing `'Unexpected state'` when called after the handshake has already completed (`SecurityState.finish`), so a defensive second `EspProv.establishSession` on a reused instance is no longer misreported as `keymismatch`.

---

## [1.0.0] - 11-24-2023 (November 24, 2023)

#### Bug Fixes:

* Fixed an issue where the app crash on iOS devices.

## [0.0.4] - 10-14-2023 (October 14, 2023)

#### Documentation Updates:

- Updated the CHANGELOG.md file to reflect the latest changes.

## [0.0.3] - 10-14-2023 (October 14, 2023)

#### Style Fixes:

- Corrected a number of linting errors to improve code quality.

## [0.0.2] - 10-12-2023 (October 12, 2023)

#### Style Fixes:

- Corrected a number of linting errors to increase pub points :)

## [0.0.1] - 10-08-2023 (October 8, 2023)

#### Initial Version of the library:

- Initial release for Espressif ESP32 BLE provisioning with protobuf and 
  cryptography, Dart 3.0 compatible. Based on version 1.0.0+2 from 
  esp_provisioning.
