import 'dart:typed_data';

/// An abstract class that must be implemented in a higher layer of software
/// (eg. a Flutter Bluetooth plugin). It provides the provisioning transport
/// functionality to [EspProv].
///
/// It must have at least the following methods implemented: `connect`,
/// `checkConnect`, `disconnect` and `sendReceive`.
abstract class ProvTransport {
  /// Starts the connection with a device. Must return `true` if it succeeds
  /// in connecting, `false` if it fails.
  Future<bool> connect();

  /// Checks if a device is connected. Must return `true` if it is connected,
  /// `false` if it isn't connected.
  Future<bool> checkConnect();

  /// Starts the disconnection of a device. Must return `true` if it succeeds
  /// in disconnecting, `false` if it fails.
  Future<bool> disconnect();

  /// Sends to write and reads to receive the necessary data to the services
  /// and characteristics of the device.
  Future<Uint8List> sendReceive(String epName, Uint8List data);
}
