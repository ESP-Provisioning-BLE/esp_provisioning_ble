# esp_provisioning_ble

[![pub package](https://img.shields.io/pub/v/esp_provisioning_ble.svg)](https://pub.dev/packages/esp_provisioning_ble)
[![pub points](https://img.shields.io/pub/points/esp_provisioning_ble)](https://pub.dev/packages/esp_provisioning_ble/score)
[![likes](https://img.shields.io/pub/likes/esp_provisioning_ble)](https://pub.dev/packages/esp_provisioning_ble/score)
[![CI](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/actions/workflows/ci.yml/badge.svg)](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

A Flutter plugin that simplifies provisioning ESP32 modules over Bluetooth Low Energy (BLE).

It is transport-agnostic: you implement a thin `ProvTransport` with the BLE package of your choice (the [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) uses [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)), and the plugin handles the secure handshake, Wi-Fi scanning, credential delivery and status reporting on top of Espressif's [protocomm](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/protocomm.html) protocol.

## Features

- Secure session establishment with Security 1 (Curve25519 key exchange + AES-CTR) using a Proof-of-Possession (PoP).
- Scan the Wi-Fi networks visible to the device, with SSID, RSSI, BSSID and whether the network is secured.
- Send Wi-Fi credentials and apply them, optionally targeting a specific access point by BSSID.
- Query the provisioning status, including the assigned device IP and the failure reason.
- Exchange arbitrary custom data over the encrypted session.
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
flutter pub add esp_provisioning_ble
```

Or add it to your `pubspec.yaml` manually and run `flutter pub get`:

```yaml
dependencies:
  esp_provisioning_ble: ^1.0.0
```

## Getting started

The package exposes an abstract `ProvTransport` class that you implement with your preferred Bluetooth package. The [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) provides a `TransportBLE` implementation built on [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus). A legacy example using [flutter_ble_lib_ios_15](https://github.com/davejlin/flutter_ble_lib_ios_15) is available in [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy).

The snippets below are plain Dart, so they fit any state-management approach.

### Create an EspProv instance

`EspProv` takes a `transport` (any `ProvTransport`) and a `security` (any `ProvSecurity`; the package ships `Security1`, which carries the Proof-of-Possession).

```dart
final prov = EspProv(
  transport: TransportBLE(peripheral),
  security: Security1(pop: pop),
);
```

### Establish a session

Call `establishSession` to run the secure handshake. It returns an `EstablishSessionStatus`:

- `connected`: the session was established successfully.
- `disconnected`: the connection to the device dropped.
- `keymismatch`: the Proof-of-Possession (PoP) is incorrect.

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
    // Wrong Proof-of-Possession.
    break;
}
```

Once the session is established `establishSession` is idempotent, so you can call it defensively without repeating the handshake.

### Scan for Wi-Fi networks

`startScanWiFi` returns a list of `WifiAP` objects, each with:

- `String ssid`
- `int rssi`
- `bool active`
- `bool private`: whether the network is secured.
- `String? bssid`: MAC-style address (`aa:bb:cc:dd:ee:ff`) when known.

```dart
final networks = await prov.startScanWiFi();
for (final ap in networks) {
  print('${ap.ssid} (${ap.rssi} dBm)');
}
```

### Send and apply the Wi-Fi config

`sendWifiConfig` delivers the credentials and returns whether the device accepted them; `applyWifiConfig` then tells the device to connect. Pass an optional `bssid` to target a specific access point.

```dart
await prov.sendWifiConfig(ssid: ssid, password: password);
// Or target a specific access point:
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

### Send and receive custom data

`sendReceiveCustomData` sends a payload over the encrypted session and returns the device's response.

```dart
final answerBytes = await prov.sendReceiveCustomData(
  Uint8List.fromList(utf8.encode(message)),
);
final answer = utf8.decode(answerBytes);
```

See the [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) (flutter_blue_plus) or [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy) (flutter_ble_lib_ios_15) for complete applications.

## Security

This package currently implements **Security 1** through the `Security1` class: a Curve25519 key exchange with AES-CTR encryption, authenticated with a Proof-of-Possession (PoP). This maps to Espressif's `protocomm_security1`.

- **Security 0** (no security) is in progress.
- **Security 2** (SRP6a key exchange + AES-GCM) is not yet available.

To use a different scheme, provide your own `ProvSecurity` implementation.

To report a security vulnerability, please follow the [security policy](SECURITY.md).

## Protocol communication overview

The [protocomm](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/protocomm.html#overview) component from ESP-IDF manages secure sessions and provides the framework for multiple transports. Applications can also use the protocomm layer directly for application-specific extensions.

It defines three security schemes:

- `protocomm_security0`: no security.
- `protocomm_security1`: Curve25519 key exchange + AES-CTR (implemented here as `Security1`).
- `protocomm_security2`: SRP6a key exchange + AES-GCM.

Proof-of-Possession is supported with security 1; salt and verifier with security 2. Protocomm uses protobuf for session establishment and provides the framework for transports such as Bluetooth LE, Wi-Fi (SoftAP + HTTPD) and console.

For security 1 and security 2 the client still needs to establish a session by performing the two-way handshake. See [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/provisioning.html) for more details on the handshake logic.

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
