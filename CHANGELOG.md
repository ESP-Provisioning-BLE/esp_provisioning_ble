# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Older entries below are preserved as originally written.

## [Unreleased]

### Added

- `WifiAP.bssid`: optional BSSID (MAC address) of the scanned access point,
  decoded from the scan protocol payload when present.

### Changed

- `WifiAP` now implements value equality (`==`/`hashCode`). Two instances are
  equal when their `bssid` matches; when neither has a `bssid`, equality
  falls back to comparing `ssid`, `rssi`, `active`, and `private`. This lets
  consumers reliably compare or deduplicate scan results, including telling
  apart APs that share the same SSID (for example, a dual-band router's
  radios). This is an observable behavior change for anyone who previously
  relied on the default identity-based equality.
- Relaxed the Dart SDK lower bound from the pre-release `3.1.0-331.0.dev` to
  the stable `3.1.0`, so the package resolves without requiring a
  pre-release SDK.

### Fixed

- Corrected offset handling in `sendReceiveCustomData`, which was resending
  data from offset 0 on every chunk instead of advancing through the buffer.

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