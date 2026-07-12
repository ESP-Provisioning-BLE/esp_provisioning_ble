import 'dart:async';

import 'package:flutter/services.dart';

/// A class for interacting with the `crypt` method of the ESP
/// Provisioning BLE plugin.
class Crypt {
  static const MethodChannel _channel = MethodChannel('esp_provisioning_ble');

  Future<bool> init(Uint8List key, Uint8List iv) async {
    return await _channel.invokeMethod('init', {
      'key': key,
      'iv': iv,
    });
  }

  Future<Uint8List> crypt(Uint8List data) async {
    return await _channel.invokeMethod(
      'crypt',
      {
        'data': data,
      },
    );
  }
}
