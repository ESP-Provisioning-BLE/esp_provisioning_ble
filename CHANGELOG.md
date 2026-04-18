# Changelog

All notable changes to this project will be documented in this file.

From version 1.1.0 onwards this file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.
Older entries below are preserved as originally written.

## [1.1.0] - 2026-04-18

### Added

- `Security0` class implementing the no-encryption (`SecScheme0`) provisioning
  handshake, for use with ESP32 firmware configured without encryption.
- `Security0State` enum (`step0Request`, `step0Response`) tracking the
  two-step Security0 session state machine.
- Unit tests for `Security0`: encrypt/decrypt identity, state transitions,
  correct protobuf output, and error handling in session response processing.
- Security mode selector in the example app: users can choose between
  Security0 (no encryption) and Security1 (encrypted) at the connect screen,
  with the proof-of-possession field shown only when Security1 is selected.

### Changed

- `ProvSecurity.securitySession` parameter changed from `SessionData` to
  `SessionData?` to reflect that the first call in a session has no prior
  response to pass.

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
