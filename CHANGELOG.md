# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with dates in ISO 8601 (`YYYY-MM-DD`). Entry text from older releases is preserved as originally written.

## [Unreleased]

### Fixed

- `sendReceiveCustomData` throws an `ArgumentError` naming `packageSize`, before sending anything, when `packageSize` is not greater than zero. With `0` and non-empty data it used to loop forever sending empty chunks to the device, and a negative value failed with a `RangeError` about an unrelated `end` argument ([#68](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/68)).

## [1.2.0] - 2026-11-15

This release makes the plugin build again on Android with current Flutter releases, adds `Security0` for devices provisioned without security, reports WPA3 networks correctly in scan results, and throws a typed exception when a scan response has an unexpected message type. It also declares Flutter 3.13.0 as the minimum, which the Dart SDK constraint already implied. There are no breaking changes in the Dart API; the move of the Android native code to a new namespace only affects code that names the plugin class directly (see Changed).

### Added

- `UnexpectedMessageTypeException`: a typed exception thrown by `startScanResponse`, `scanStatusResponse` and `scanResultResponse` (and so by `scan`/`startScanWiFi`) when the device answers with a message type other than the one expected. It exposes `expectedType`, `expectedValue`, `actualType`, `actualValue` and `payload` using only core Dart types. It implements `Exception` and its `toString()` is identical to the plain `Exception('Invalid expected message type ...')` thrown before, so existing `on Exception`, `catch (e)` and string-comparing code keeps working unchanged.
- The `WPA3_PSK` (6) and `WPA2_WPA3_PSK` (7) auth modes in the `WifiAuthMode` protobuf enum, matching `wifi_constants.proto` in ESP-IDF v5.4, so scan results from WPA3 networks decode to a known mode ([#19](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/pull/19)). Thanks to @xiayesuifeng for the contribution.
- `Security0`: the no-encryption (`SecScheme0`) provisioning handshake, for ESP32 firmware configured with `WIFI_PROV_SECURITY_0`, and the `Security0State` enum that tracks it (`step0Request`, `step0Response`, `finish`). Pass it to `EspProv` like `Security1`; `encrypt` and `decrypt` return the data unchanged, and a response without a Security0 session payload is rejected. No existing signature changes, so classes that implement `ProvSecurity` keep compiling. Thanks to @milan-trkulja-metaswiss for the original contribution ([#18](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/pull/18)).
- Example app: a Security 0 / Security 1 selector on the connect screen, with the proof-of-possession field shown only for Security 1.

### Changed

- Declared Flutter 3.13.0 as the minimum (`flutter: ">=3.13.0"`, previously `>=1.17.0`). The Dart SDK constraint (`>=3.1.0`) already required it, so nobody who could install the package before is excluded.
- Moved the Android native code from `com.ogabrielinacio.esp_provisioning_ble` to the organization's namespace, `dev.espprovble.esp_provisioning_ble` ([#36](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/36)). The Dart API and the method channel are unchanged, and Flutter regenerates the plugin registrant on the next build. Only code that names the plugin class directly, such as a manual registration on a custom `FlutterEngine`, has to switch to `dev.espprovble.esp_provisioning_ble.EspProvisioningBlePlugin`. A ProGuard or R8 rule that names the old class now matches nothing; the plugin does not need one.

### Fixed

- Android builds with current Flutter releases ([#54](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/54)). The plugin compiled against API 33, which apps on AGP 8.13 or later (required since Flutter 3.50) reject, and new apps failed to build from Flutter 3.44. It now compiles against API 34, targets Java 11, and applies the Kotlin Gradle Plugin only when Flutter or AGP has not already done so, which also removes Flutter's Kotlin Gradle Plugin warning. `minSdk` stays at 19.
- `WifiAP.private` reported WPA3 networks, and any other auth mode the bindings did not know, as open (`private: false`). ESP-IDF sends its raw `wifi_auth_mode_t` (0 to 15 in v5.4), and protobuf decodes values missing from the `WifiAuthMode` enum as `Open`. `private` is now computed from the numeric mode: only Open and OWE (Enhanced Open, which needs no password) count as open, and every other mode, known or not, is private. It also no longer compares enum names, so apps built with `protobuf.omit_enum_names` no longer see every network as private.

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
