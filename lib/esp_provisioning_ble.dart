/// Provisions ESP32 devices over Bluetooth Low Energy with Espressif's
/// unified provisioning protocol (protocomm).
///
/// The entry point is [EspProv], which runs the provisioning flow on top of
/// two pieces you choose:
///
/// - a [ProvTransport], which you implement with the BLE package of your
///   choice to send each request to a protocomm endpoint of the device and
///   return its response;
/// - a [ProvSecurity], which must match the security scheme of the device
///   firmware: [Security1] (Curve25519 key exchange, AES-CTR encryption and
///   an optional proof of possession) or [Security0] (no encryption).
///
/// A typical flow establishes the session, scans the Wi-Fi networks that the
/// device can see, sends and applies the credentials and then polls the
/// connection status:
///
/// ```dart
/// final prov = EspProv(
///   transport: myTransport,
///   security: Security1(pop: 'abcd1234'),
/// );
/// if (await prov.establishSession() == EstablishSessionStatus.connected) {
///   final networks = await prov.startScanWiFi();
///   await prov.sendWifiConfig(ssid: networks.first.ssid, password: 'secret');
///   await prov.applyWifiConfig();
///   final status = await prov.getStatus();
/// }
/// ```
library;

export 'src/esp_prov.dart';
export 'src/security.dart';
export 'src/security0.dart';
export 'src/security1.dart';
export 'src/transport.dart';
export 'src/connection_models.dart';
export 'src/unexpected_message_type_exception.dart';
