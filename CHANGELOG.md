# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with dates in ISO 8601 (`YYYY-MM-DD`). Entry text from older releases is preserved as originally written.

## [Unreleased]

## [1.1.0] - 2026-07-19

This is the first release published under the ESP-Provisioning-BLE organization. It focuses on unblocking installation on a stable Dart SDK, adding BSSID support, and fixing genuine issues carried over from 1.0.0. These changes should not affect existing users negatively; if anything does, please open an issue, they are very welcome.

### Added

- `WifiAP.bssid`: optional BSSID (MAC address) of a scanned access point, decoded from the scan payload when present and rendered in standard colon-separated MAC notation.
- `sendWifiConfig` accepts an optional `bssid` to target a specific access point; malformed values are rejected with a clear `FormatException`.

### Changed

- `WifiAP` now implements value equality (`==`/`hashCode`): equal when the `bssid` matches, or (when neither has one) by `ssid`, `rssi`, `active`, and `private`. This is an observable behavior change for anyone who relied on the default identity-based equality.
- Relaxed the Dart SDK lower bound from the pre-release `3.1.0-331.0.dev` to the stable `3.1.0`, so the package resolves on a stable SDK.
- Updated package metadata (homepage, repository, issue tracker, topics, description) for the new organization and dedicated domain.

### Fixed

- `Security1.securitySession` now returns `null` instead of throwing `'Unexpected state'` when called after the handshake has already completed (`SecurityState.finish`), so a defensive second `EspProv.establishSession` on a reused instance is no longer misreported as `keymismatch`.
- Corrected offset handling in `sendReceiveCustomData`, which was resending data from offset 0 on every chunk instead of advancing through the buffer, corrupting payloads larger than one chunk.

---

## [1.0.0] - 2023-11-24

#### Bug Fixes:

* Fixed an issue where the app crash on iOS devices.

## [0.0.4] - 2023-10-14

#### Documentation Updates:

- Updated the CHANGELOG.md file to reflect the latest changes.

## [0.0.3] - 2023-10-14

#### Style Fixes:

- Corrected a number of linting errors to improve code quality.

## [0.0.2] - 2023-10-12

#### Style Fixes:

- Corrected a number of linting errors to increase pub points :)

## [0.0.1] - 2023-10-08

#### Initial Version of the library:

- Initial release for Espressif ESP32 BLE provisioning with protobuf and
  cryptography, Dart 3.0 compatible. Based on version 1.0.0+2 from
  esp_provisioning.
