# esp_provisioning_ble

[![pub package](https://img.shields.io/pub/v/esp_provisioning_ble.svg)](https://pub.dev/packages/esp_provisioning_ble)
[![pub points](https://img.shields.io/pub/points/esp_provisioning_ble)](https://pub.dev/packages/esp_provisioning_ble/score)
[![likes](https://img.shields.io/pub/likes/esp_provisioning_ble)](https://pub.dev/packages/esp_provisioning_ble/score)
[![CI](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/actions/workflows/ci.yml/badge.svg)](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

A Flutter plugin that simplifies provisioning ESP32 modules over Bluetooth Low Energy (BLE).

It is transport-agnostic: you implement a thin `ProvTransport` with the BLE package of your choice (the [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) uses [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)), and the plugin handles the session handshake, Wi-Fi scanning, credential delivery and status reporting on top of Espressif's [protocomm](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/protocomm.html) protocol.

> [!IMPORTANT]
> Version 2.0 is in development on the [`release/v2.0.0`](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/release/v2.0.0) branch and is published as pre-releases, starting with `2.0.0-dev.1`. It moves to `protobuf ^6.0.0` and requires Dart 3.7 and Flutter 3.29 or later. The 1.x line, released from `main`, is still the stable version and keeps receiving fixes. Read the [announcement](https://github.com/orgs/ESP-Provisioning-BLE/discussions/75) for what changes and how to try the pre-release.

## Features

- Secure session establishment with Security 1 (Curve25519 key exchange + AES-CTR) using a Proof-of-Possession (PoP).
- Unencrypted sessions with Security 0, for devices provisioned without security.
- Scan the Wi-Fi networks visible to the device, with SSID, RSSI, BSSID and whether the network needs credentials.
- Send Wi-Fi credentials and apply them, optionally with the BSSID of a specific access point (used only if the device firmware applies it).
- Query the provisioning status, including the assigned device IP and the failure reason.
- Exchange arbitrary custom data over the provisioning session.
- Transport-agnostic: bring your own BLE stack by implementing `ProvTransport`.

## Supported platforms

| Platform | Support |
| -------- | :-----: |
| Android  | ✅      |
| iOS      | ✅      |

The plugin logic is pure Dart on top of your `ProvTransport`, so the platform reach is ultimately bounded by the BLE package you plug in.

## Table of contents

- [Features](#features)
- [Supported platforms](#supported-platforms)
- [Installation](#installation)
- [Getting started](#getting-started)
  - [Create an EspProv instance](#create-an-espprov-instance)
  - [Establish a session](#establish-a-session)
  - [Scan for Wi-Fi networks](#scan-for-wi-fi-networks)
  - [Send and apply the Wi-Fi config](#send-and-apply-the-wi-fi-config)
  - [Check the provisioning status](#check-the-provisioning-status)
  - [Wi-Fi connection retries](#wi-fi-connection-retries)
  - [Send and receive custom data](#send-and-receive-custom-data)
- [Security](#security)
- [Protocol communication overview](#protocol-communication-overview)
- [Comparison](#comparison)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## Installation

Add the package with:

```sh
flutter pub add "esp_provisioning_ble:^2.0.0-dev.1"
```

Or add it to your `pubspec.yaml` manually and run `flutter pub get`:

```yaml
dependencies:
  esp_provisioning_ble: ^2.0.0-dev.1
```

For the stable 1.x line (protobuf 3, Flutter 3.13 or later), use `^1.2.1`. To move from 1.x, see [Migrating from 1.x](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/blob/v2.0.0-dev.1/CHANGELOG.md#migrating-from-1x) in the changelog.

It requires Flutter 3.29 or later (Dart 3.7 or later). On Android the plugin's `minSdk` is 19; your app's own `minSdk` may be higher.

## Getting started

The package exposes an abstract `ProvTransport` class that you implement with your preferred Bluetooth package. The [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) provides a `TransportBLE` implementation built on [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus). A legacy example using [flutter_ble_lib_ios_15](https://github.com/davejlin/flutter_ble_lib_ios_15) is available in [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy).

The snippets below are plain Dart, so they fit any state-management approach.

### Create an EspProv instance

`EspProv` takes a `transport` (any `ProvTransport`) and a `security` (any `ProvSecurity`). The package ships `Security1`, which carries the Proof-of-Possession, and `Security0`, for devices provisioned without security. Use the one that matches the security scheme of the device firmware.

```dart
final prov = EspProv(
  transport: TransportBLE(peripheral),
  security: Security1(pop: pop),
);

// For a device provisioned without security:
final openProv = EspProv(
  transport: TransportBLE(peripheral),
  security: Security0(),
);
```

### Establish a session

Call `establishSession` to run the session handshake. It returns an `EstablishSessionStatus`:

- `connected`: the session was established successfully.
- `disconnected`: the device is not connected, or the handshake failed and the connection was already closed.
- `keymismatch`: the handshake failed while the device was still connected, whatever the cause. With `Security1` a common cause is a wrong Proof-of-Possession (PoP); with `Security0`, that the device's answer was not a valid Security 0 response; an empty or undecodable response, or a transport error, gives it too.

After a failed handshake the status only reflects whether the device was still connected, not the cause of the failure. A wrong PoP comes back as `keymismatch` if the device is still connected when the plugin checks, and as `disconnected` if the device has already closed the connection. Telling the causes apart is planned in [#37](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/37).

```dart
final status = await prov.establishSession();
switch (status) {
  case EstablishSessionStatus.connected:
    // Ready to scan and send Wi-Fi credentials.
    break;
  case EstablishSessionStatus.disconnected:
    // Handle the dropped connection.
    break;
  case EstablishSessionStatus.keymismatch:
    // Handshake failed, for example because of a wrong Proof-of-Possession.
    break;
}
```

Once the session is established `establishSession` is idempotent, so you can call it defensively without repeating the handshake.

### Scan for Wi-Fi networks

`startScanWiFi` returns a list of `WifiAP` objects, each with:

- `String ssid`
- `int rssi`
- `bool active`
- `bool private`: whether joining the network needs credentials. It is `false` only for Open and OWE (Wi-Fi Enhanced Open) networks, and `true` for every other auth mode, including WPA3 and any mode this package does not know yet.
- `String? bssid`: MAC-style address (`aa:bb:cc:dd:ee:ff`) when known.

```dart
final networks = await prov.startScanWiFi();
for (final ap in networks) {
  print('${ap.ssid} (${ap.rssi} dBm)');
}
```

If the device answers a scan request with a message of an unexpected type (for example a corrupted or out-of-order BLE message), `startScanWiFi` throws an `UnexpectedMessageTypeException`, which exposes the expected and received message types. It implements `Exception`, so an existing `on Exception` or `catch (e)` handler still catches it.

### Send and apply the Wi-Fi config

`sendWifiConfig` delivers the credentials and returns whether the device accepted them; `applyWifiConfig` then tells the device to connect. Pass an optional `bssid` to ask for a specific access point.

The `bssid` is always sent, but whether the device uses it depends on its firmware. ESP-IDF's stock provisioning manager (checked on v5.4 and v5.5) validates its length and then drops it, so the device joins the network by SSID and the Wi-Fi driver picks the access point. To join a specific access point, the firmware has to apply the BSSID itself, as the [test firmware](https://github.com/ESP-Provisioning-BLE/esp_provisioning_test_firmware) does with `CONFIG_TESTFW_APPLY_BSSID`.

```dart
await prov.sendWifiConfig(ssid: ssid, password: password);
// Or ask for a specific access point (only firmware that applies the BSSID uses it):
// await prov.sendWifiConfig(ssid: ssid, password: password, bssid: 'aa:bb:cc:dd:ee:ff');
await prov.applyWifiConfig();
```

### Check the provisioning status

`getStatus` returns a `ConnectionStatus` with:

- `WifiConnectionState state`: `Connecting`, `Connected`, `Disconnected` or `ConnectionFailed`.
- `String? deviceIp`: the device IP once connected.
- `WifiConnectFailedReason? failedReason`: `AuthError` (wrong password) or `NetworkNotFound` (wrong SSID), set when the state is `ConnectionFailed`.

```dart
final status = await prov.getStatus();
switch (status.state) {
  case WifiConnectionState.Connecting:
    // Still connecting.
    break;
  case WifiConnectionState.Connected:
    print('Device IP: ${status.deviceIp}');
    break;
  case WifiConnectionState.Disconnected:
    // Not connected.
    break;
  case WifiConnectionState.ConnectionFailed:
    // Inspect status.failedReason.
    break;
}
```

### Wi-Fi connection retries

The plugin does not retry a failed Wi-Fi connection and does not follow the retries of the ESP32: `getStatus` returns what the device reports at the moment it is called. Whether and how the device retries is decided by its firmware. With ESP-IDF's provisioning manager (checked on v5.4 and v5.5):

- `wifi_prov_conn_cfg.wifi_conn_attempts` in the manager configuration sets how many connection attempts the device makes. While attempts remain, `getStatus` reports `Connecting`; the number of remaining attempts is not exposed by this plugin. When they run out, it reports `ConnectionFailed`.
- With the default, `0`, an authentication error or a network that is not found is reported as `ConnectionFailed` right away, and other disconnections are retried while `getStatus` reports `Connecting`.
- The application code of the firmware can retry as well. ESP-IDF's `wifi_prov_mgr` example calls `esp_wifi_connect()` again on every disconnection, so a device that reported `ConnectionFailed` can still connect later and report `Connected`, unless the firmware resets the provisioning state first.
- Once the device has received credentials, it rejects new ones until the firmware resets the provisioning state with `wifi_prov_mgr_reset_sm_state_on_failure()` after a failure. Until then `sendWifiConfig` still returns `true`, but `applyWifiConfig` returns `false`. Reconnecting over BLE does not reset that state. The ESP-IDF example resets it on failure when `CONFIG_EXAMPLE_RESET_PROV_MGR_ON_FAILURE` is enabled, which is its default.

What this means for your app:

- Keep polling `getStatus` while it reports `Connecting`, with a timeout of your own.
- Treat `ConnectionFailed` as final only if you know that the firmware stops retrying. Otherwise keep polling for a while, or tell the user that the device may still be trying.
- Before letting the user try other credentials after a failure, check the result of `applyWifiConfig`: `false` means that the device does not accept them yet, and the firmware has to reset its provisioning state first.
- If you control the firmware, a limited number of attempts plus a reset of the provisioning state on failure gives the app a clear `ConnectionFailed` and lets it send new credentials in the same session.

### Send and receive custom data

`sendReceiveCustomData` sends a payload over the session (encrypted with `Security1`, in the clear with `Security0`) and returns the device's response.

```dart
final answerBytes = await prov.sendReceiveCustomData(
  Uint8List.fromList(utf8.encode(message)),
);
final answer = utf8.decode(answerBytes);
```

See the [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) (flutter_blue_plus) or [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy) (flutter_ble_lib_ios_15) for complete applications.

## Security

This package implements two of Espressif's security schemes:

- **Security 1** through the `Security1` class: a Curve25519 key exchange with AES-CTR encryption, authenticated with a Proof-of-Possession (PoP). This maps to Espressif's `protocomm_security1`.
- **Security 0** through the `Security0` class: no encryption and no Proof-of-Possession, so everything, including the Wi-Fi password, travels in the clear over BLE. This maps to `protocomm_security0` and is meant for devices whose firmware is built without security (`WIFI_PROV_SECURITY_0`).
- **Security 2** (SRP6a key exchange + AES-GCM) is not yet available.

To use a different scheme, provide your own `ProvSecurity` implementation.

To report a security vulnerability, please follow the [security policy](SECURITY.md).

## Protocol communication overview

The [protocomm](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/protocomm.html#overview) component from ESP-IDF manages secure sessions and provides the framework for multiple transports. Applications can also use the protocomm layer directly for application-specific extensions.

It defines three security schemes:

- `protocomm_security0`: no security (implemented here as `Security0`).
- `protocomm_security1`: Curve25519 key exchange + AES-CTR (implemented here as `Security1`).
- `protocomm_security2`: SRP6a key exchange + AES-GCM.

Proof-of-Possession is supported with security 1; salt and verifier with security 2. Protocomm uses protobuf for session establishment and provides the framework for transports such as Bluetooth LE, Wi-Fi (SoftAP + HTTPD) and console.

For security 1 and security 2 the client still needs to establish a session by performing the two-way handshake. See [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/provisioning.html) for more details on the handshake logic. With security 0 there is no key exchange, but `establishSession` still runs one request/response round with the device before the session is ready.

## Comparison

`esp_provisioning_ble` is the Bluetooth LE counterpart to [esp_provisioning_softap](https://github.com/nicop2000/esp_provisioning_softap): this package provisions the device over Bluetooth LE, while `esp_provisioning_softap` provisions it over Wi-Fi SoftAP. Both build on the protocomm security schemes and protobuf.

## Changelog

See the [CHANGELOG](CHANGELOG.md) for the release history.

## Contributing

Contributions are welcome. Please read the [contributing guide](CONTRIBUTING.md) to get set up and learn the workflow. This project follows a [Code of Conduct](CODE_OF_CONDUCT.md), and security issues are handled through our [security policy](SECURITY.md).

## Credits

- Based on [esp_provisioning](https://github.com/unicloudvn/esp_provisioning/tree/master).
- Also references [esp_provisioning_softap](https://github.com/nicop2000/esp_provisioning_softap), a Dart 3.0-compatible version of [esp_softap_provisioning](https://github.com/omert08/esp_softap_provisioning).

## License

Released under the [MIT License](LICENSE).
