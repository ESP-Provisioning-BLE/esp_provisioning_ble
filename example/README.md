# ESP32 BLE Provisioning Example

Example Flutter app demonstrating how to provision an ESP32 over BLE using
[`esp_provisioning_ble`](https://pub.dev/packages/esp_provisioning_ble) and
[`flutter_blue_plus`](https://pub.dev/packages/flutter_blue_plus).

> Looking for the legacy example built with
> [`flutter_ble_lib_ios_15`](https://github.com/davejlin/flutter_ble_lib_ios_15)?
> See [`example_legacy/`](../example_legacy/).

## Features

- BLE device scanning with keyword (substring) or exact-name filtering
- Secure session establishment (Curve25519 key exchange via Security1)
- WiFi network scan through the ESP32
- WiFi credential provisioning with connection status polling
- Custom data exchange with the device

## Requirements

### Android

The following permissions are declared in `AndroidManifest.xml`:

- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`
- `ACCESS_FINE_LOCATION` (required for BLE scanning on most Android devices)

The app requests `locationWhenInUse` at runtime before starting a scan.

### iOS

Add these keys to `Info.plist`:

- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription` (iOS 12 and earlier)

## Project Structure

```
lib/
  main.dart                          App entry point and route table
  src/
    screens/
      home_screen.dart               Start screen
      scan_screen.dart               BLE device scanner with filter UI
      connect_screen.dart            PoP entry and session establishment
      wifi_screen.dart               WiFi scan, selection, and provisioning
    services/
      ble_scanner.dart               BLE scanning via flutter_blue_plus
      provisioning_service.dart      Provisioning state machine (ChangeNotifier)
      transport_ble.dart             ProvTransport implementation for FBP
    widgets/
      device_list_tile.dart          BLE device list item
      wifi_list_tile.dart            WiFi network list item with signal icon
      wifi_password_dialog.dart      Password entry dialog
```

## Running

```bash
cd example
flutter pub get
flutter run
```

## Tests

```bash
cd example
flutter test
```

Unit tests cover the provisioning service state machine, BLE scanner initial
state, WiFi list tile signal icons, and the WiFi credentials data class.
