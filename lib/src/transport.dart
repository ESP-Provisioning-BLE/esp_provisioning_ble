import 'dart:typed_data';

/// The link between [EspProv] and the device, which you implement with the
/// Bluetooth package of your choice.
///
/// The package does not ship any implementation. The example app has one
/// built on `flutter_blue_plus`.
///
/// With ESP-IDF's provisioning manager over BLE, each protocomm endpoint is
/// a GATT characteristic of the provisioning service. Its 128-bit UUID is
/// the service UUID with two bytes replaced by the endpoint's 16-bit value
/// (`0xff50` for `prov-scan`, `0xff51` for `prov-session`, `0xff52` for
/// `prov-config`, `0xff53` for `proto-ver`, and the following values for
/// custom endpoints in the order the firmware creates them), and its user
/// description descriptor (`0x2901`) holds the endpoint name. A request is
/// written to the characteristic and the response is read back from it.
abstract class ProvTransport {
  /// Connects to the device and returns whether it succeeded.
  ///
  /// [EspProv] never calls it: connect before calling
  /// [EspProv.establishSession].
  Future<bool> connect();

  /// Returns whether the device is connected right now.
  ///
  /// [EspProv.establishSession] calls it before each round of the handshake
  /// and after an error, to tell [EstablishSessionStatus.disconnected] from
  /// [EstablishSessionStatus.keymismatch].
  Future<bool> checkConnect();

  /// Disconnects from the device and returns whether it succeeded.
  ///
  /// [EspProv.dispose] calls it and ignores the result.
  Future<bool> disconnect();

  /// Sends [data] to the protocomm endpoint named [epName] and returns the
  /// device's response.
  ///
  /// [EspProv] uses the endpoints `prov-session`, `prov-scan`, `prov-config`
  /// and `custom-data`. [data] is already encrypted by the [ProvSecurity] in
  /// use, and the response is returned as received, without decrypting it.
  /// An error thrown here reaches the caller of the [EspProv] method, except
  /// in [EspProv.establishSession], which turns it into a status.
  Future<Uint8List> sendReceive(String epName, Uint8List data);
}
