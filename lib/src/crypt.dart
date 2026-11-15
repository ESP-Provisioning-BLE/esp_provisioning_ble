import 'dart:async';

import 'package:flutter/services.dart';

/// AES-CTR cipher of [Security1], implemented in the plugin's native code.
///
/// It calls the `esp_provisioning_ble` method channel. The native side keeps
/// a single cipher, which [init] replaces. Not exported by the package.
class Crypt {
  static const MethodChannel _channel = MethodChannel('esp_provisioning_ble');

  /// Sets up the native AES-CTR cipher with [key] and the nonce [iv],
  /// replacing any previous one. Returns the result of the native call.
  Future<bool> init(Uint8List key, Uint8List iv) async {
    return await _channel.invokeMethod('init', {'key': key, 'iv': iv});
  }

  /// Encrypts or decrypts [data] with the native cipher, advancing its
  /// counter. In AES-CTR both are the same operation.
  Future<Uint8List> crypt(Uint8List data) async {
    return await _channel.invokeMethod('crypt', {'data': data});
  }
}
