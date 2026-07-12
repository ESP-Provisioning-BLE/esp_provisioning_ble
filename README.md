# esp_provisioning_ble

A library for provisioning a ESP32 with Bluetooth BLE

<p> 
  <a href="https://ko-fi.com/ogabrielinacio" target="_blank"> <img src="https://ko-fi.com/img/githubbutton_sm.svg"/> </a> 
</p>

## Getting Started

### Create an EspProv Instance

The package has an abstract class called `ProvTransport`, that you need to implement using your preferred Bluetooth package. In the [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example)

folder there is an implementation of `ProvTransport` using [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus). A legacy example using [flutter_ble_lib_ios_15](https://github.com/davejlin/flutter_ble_lib_ios_15) is available in [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy).

```dart
prov = EspProv(
    transport: TransportBLE(peripheral),
    security: Security1(
        pop: pop,
    ),
);
```

The `transport` attribute accepts only the `ProvTransport` type, and the `security` attribute accepts only the `ProvSecurity` type, which has an implementation called `Security1` that you will use to pass the Proof-of-Possession (PoP).

### Establish a session with the device:

After that, you will need to establish a session with the device. You can do this using the `establishSession` function, which returns three types of `EstablishSessionStatus`:

1. `Connected`: When the device establishes a connection successfully.
2. `Disconnected`: When an error occurs while establishing a connection with the device.
3. `KeyMismatch`: When the Proof-of-Possession (PoP) is incorrect.

```dart
var sessionStatus = await prov.establishSession();
log.d("Session Status = $sessionStatus");
switch (sessionStatus) {
    case EstablishSessionStatus.Connected:
        emit(BleWifiEstablishedConnectionState());
    case EstablishSessionStatus.Disconnected:
        emit(BleWifiEstablishedConnectionFailedState());
    case EstablishSessionStatus.Keymismatch:
        emit(BleWifiEstablishedConnectionKeyMismatch());
}
```

### Scan networks from the device:

To scan Wi-Fi networks, use the `startScanWifi` function, which returns a list of `WifiAp` objects, each of which has the following attributes:

1. `String ssid`
2. `int rssi`
3. `bool active`
4. `bool private`

```dart
var listWifi = await prov.startScanWiFi();
log.d('Found ${listWifi.length} Wi-Fi networks');
for (var obj in listWifi) {
    log.d('Wi-Fi network: ${obj.ssid}');
}
```

### Send and Apply WI-Fi Config:

To send and apply  config use the `sendWifiConfig` and `applyWifiConfig`  functions, respectively.

```dart
await prov.sendWifiConfig(ssid: event.ssid, password: event.password);
await prov.applyWifiConfig();
```

### Get the status of applying Wi-Fi Config:

To retrieve the status, use the `getStatus` function, which returns a `ConnectionStatus` type. `ConnectionStatus` has the following attributes:

1. `WifiConnectionState state`: `WifiConnectionState` has four types of states:
   
   - Connected.
   - Connecting.
   - Disconnected.
   - ConnectionFailed: When the state is `ConnectionFailed`, the `WifiConnectFailedReason` attribute indicates the type of error.

2. `String? deviceIp`: This registers the device's IP after provisioning.

3. `WifiConnectFailedReason? failedReason`: `WifiConnectFailedReason` has two types of failed reasons:
   
   - AuthError: When the Wi-Fi password was incorrectly typed.
   - NetworkNotFound: When the Wi-Fi SSID was incorrectly typed.

```dart
ConnectionStatus status = await prov.getStatus();
switch (status.state) {
    case WifiConnectionState.Connecting:
    {
        add(BleWifiLoadingEvent());
    }
    case WifiConnectionState.Connected:
    {
        log.d("Device IP: ${status.deviceIp}");
        add(BleWifiConnectedEvent());
    }
    case WifiConnectionState.Disconnected:
    {
        add(BleWifiDisconnectedEvent());
    }
    case WifiConnectionState.ConnectionFailed:
    {
        add(
            BleWifiConnectionFailedEvent(
                failedReason: status.failedReason!,
            ),
        );
    }
}
```

## Send custom data:

To send and receive a custom data, use the `sendReceiveCustomData`  function

```dart
var customAnswerBytes = await prov.sendReceiveCustomData(
    Uint8List.fromList(
        utf8.encode(customSendMessage),
    ),
);
var customAnswer = utf8.decode(customAnswerBytes);
log.i("Custom data answer: $customAnswer");
```

Check [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example) application (flutter_blue_plus) or [example_legacy](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example_legacy) (flutter_ble_lib_ios_15).

### Protocol Communication Overview

The Protocol Communication ([protocomm](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/protocomm.html#overview)) component manages secure 
sessions and provides the framework for multiple transports. The 
application can also use the protocomm layer directly to have 
application-specific extensions for the provisioning or non-provisioning
 use cases.

Following features are available for provisioning:

* Communication security at the application level
  
  * `protocomm_security0` (no security)
  
  * `protocomm_security1` (Curve25519 key exchange + AES-CTR encryption/decryption)
  
  * `protocomm_security2` (SRP6a-based key exchange + AES-GCM encryption/decryption)

* Proof-of-possession (support with protocomm_security1 only)

* Salt and Verifier (support with protocomm_security2 only)

Protocomm internally uses protobuf (protocol buffers) for secure 
session establishment. Users can choose to implement their own security 
(even without using protobuf). Protocomm can also be used without any 
security layer.

Protocomm provides the framework for various transports:

- Bluetooth LE

- Wi-Fi (SoftAP + HTTPD)

- Console, in which case the handler invocation is automatically 
  taken care of on the device side. See Transport Examples below for code 
  snippets.

Note that for protocomm_security1 and protocomm_security2, the client
 still needs to establish sessions by performing the two-way handshake. 
See [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/provisioning.html) for more details about the secure handshake logic.

### Comparasion:

Comparison with esp_provisioning_softap package:

| Repo                    | softap support | ble support | cryptography | protobuf   |
| ----------------------- | -------------- | ----------- | ------------ | ---------- |
| esp_provisioning_softap | ✔️             | ✖️          | ✔️ (2.0.1)   | ✔️ (2.0.0) |
| esp_provisioning_ble    | ✖️             | ✔️          | ✔️ (2.5.0)   | ✔️ (3.0.0) |

Last update: 10/06/2023 (Octorber 6, 2023).

#### TODOS:

- ~~Test and create examples of the package with others Bluetooth packages.~~

  * ~~flutter_blue_plus~~ (done — see [example](https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/tree/main/example))

- Implement security 0
- Implement security 2

### Credits

- Code based on [esp_provisioning](https://github.com/unicloudvn/esp_provisioning/tree/master).
- I also referenced [esp_provisioning_softap](https://github.com/nicop2000/esp_provisioning_softap), which is a Dart 3.0 compatible version from [esp_softap_provisioning](https://github.com/omert08/esp_softap_provisioning).
