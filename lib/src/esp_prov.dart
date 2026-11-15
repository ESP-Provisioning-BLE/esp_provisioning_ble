import 'dart:convert';
import 'dart:typed_data';

import 'package:esp_provisioning_ble/src/connection_models.dart';
import 'package:flutter/widgets.dart';

import 'protos/generated/constants.pbenum.dart';
import 'protos/generated/session.pb.dart';
import 'protos/generated/wifi_config.pb.dart';
import 'protos/generated/wifi_scan.pb.dart';
import 'security.dart';
import 'transport.dart';

enum EstablishSessionStatus {
  connected,
  disconnected,
  keymismatch,
}

class EspProv {
  ProvTransport transport;
  ProvSecurity security;

  EspProv({required this.transport, required this.security});

  Future<EstablishSessionStatus> establishSession() async {
    try {
      SessionData responseData = SessionData();
      while (await transport.checkConnect()) {
        var request = await security.securitySession(responseData);
        if (request == null) {
          return EstablishSessionStatus.connected;
        }
        var response = await transport.sendReceive(
            'prov-session', request.writeToBuffer());
        if (response.isEmpty) {
          throw Exception('Empty response');
        }
        responseData = SessionData.fromBuffer(response);
      }
      return EstablishSessionStatus.disconnected;
    } catch (e) {
      if (await transport.checkConnect()) {
        return EstablishSessionStatus.keymismatch;
      } else {
        debugPrint('-----------------------');
        debugPrint('EstablishSession Error:');
        debugPrint('$e');
        debugPrint('-----------------------');
        return EstablishSessionStatus.disconnected;
      }
    }
  }

  Future<void> dispose() async {
    await transport.disconnect();
  }

  Future<List<WifiAP>> startScanWiFi() async {
    return await scan();
  }

  Future<WiFiScanPayload> startScanResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStart) {
      throw Exception('Invalid expected message type $respPayload');
    }
    return respPayload;
  }

  Future<WiFiScanPayload> startScanRequest(
      {bool blocking = true,
      bool passive = false,
      int groupChannels = 5,
      int periodMs = 0}) async {
    WiFiScanPayload payload = WiFiScanPayload();
    payload.msg = WiFiScanMsgType.TypeCmdScanStart;

    CmdScanStart scanStart = CmdScanStart();
    scanStart.blocking = blocking;
    scanStart.passive = passive;
    scanStart.groupChannels = groupChannels;
    scanStart.periodMs = periodMs;
    payload.cmdScanStart = scanStart;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-scan', reqData);
    return await startScanResponse(respData);
  }

  Future<WiFiScanPayload> scanStatusResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStatus) {
      throw Exception('Invalid expected message type $respPayload');
    }
    return respPayload;
  }

  Future<WiFiScanPayload> scanStatusRequest() async {
    WiFiScanPayload payload = WiFiScanPayload();
    payload.msg = WiFiScanMsgType.TypeCmdScanStatus;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-scan', reqData);
    return await scanStatusResponse(respData);
  }

  Future<List<WifiAP>> scanResultRequest(
      {int startIndex = 0, int count = 0}) async {
    WiFiScanPayload payload = WiFiScanPayload();
    payload.msg = WiFiScanMsgType.TypeCmdScanResult;

    CmdScanResult cmdScanResult = CmdScanResult();
    cmdScanResult.startIndex = startIndex;
    cmdScanResult.count = count;

    payload.cmdScanResult = cmdScanResult;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-scan', reqData);
    return await scanResultResponse(respData);
  }

  Future<List<WifiAP>> scanResultResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanResult) {
      throw Exception('Invalid expected message type $respPayload');
    }
    List<WifiAP> ret = [];
    for (var entry in respPayload.respScanResult.entries) {
      ret.add(WifiAP(
          ssid: utf8.decode(entry.ssid),
          // Firmware-sourced data, not user input: a length other than 6
          // bytes is treated as "no bssid" rather than thrown, the same way
          // empty bytes already are, so one malformed scan entry doesn't
          // break the whole scan.
          bssid: entry.bssid.length == 6 ? _decodeBssid(entry.bssid) : null,
          rssi: entry.rssi,
          private: _isPrivateAuthMode(_rawAuthMode(entry))));
    }
    return ret;
  }

  Future<List<WifiAP>> scan(
      {bool blocking = true,
      bool passive = false,
      int groupChannels = 5,
      int periodMs = 0}) async {
    await startScanRequest(
        blocking: blocking,
        passive: passive,
        groupChannels: groupChannels,
        periodMs: periodMs);
    var status = await scanStatusRequest();
    var resultCount = status.respScanStatus.resultCount;
    List<WifiAP> ret = [];
    if (resultCount > 0) {
      var index = 0;
      var remaining = resultCount;
      while (remaining > 0) {
        var count = remaining > 4 ? 4 : remaining;
        var data = await scanResultRequest(startIndex: index, count: count);
        ret.addAll(data);
        remaining -= count;
        index += count;
      }
    }
    return ret;
  }

  Future<bool> sendWifiConfig(
      {required String ssid, required String password, String? bssid}) async {
    var payload = WiFiConfigPayload();
    payload.msg = WiFiConfigMsgType.TypeCmdSetConfig;

    var cmdSetConfig = CmdSetConfig();
    cmdSetConfig.ssid = utf8.encode(ssid);
    cmdSetConfig.passphrase = utf8.encode(password);

    if (bssid != null) {
      cmdSetConfig.bssid = _encodeBssid(bssid);
    }

    payload.cmdSetConfig = cmdSetConfig;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-config', reqData);
    var respRaw = await security.decrypt(respData);
    var respPayload = WiFiConfigPayload.fromBuffer(respRaw);
    return (respPayload.respSetConfig.status == Status.Success);
  }

  Future<bool> applyWifiConfig() async {
    var payload = WiFiConfigPayload();
    payload.msg = WiFiConfigMsgType.TypeCmdApplyConfig;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-config', reqData);
    var respRaw = await security.decrypt(respData);
    var respPayload = WiFiConfigPayload.fromBuffer(respRaw);
    return (respPayload.respApplyConfig.status == Status.Success);
  }

  Future<ConnectionStatus> getStatus() async {
    var payload = WiFiConfigPayload();
    payload.msg = WiFiConfigMsgType.TypeCmdGetStatus;

    var cmdGetStatus = CmdGetStatus();
    payload.cmdGetStatus = cmdGetStatus;

    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-config', reqData);
    var respRaw = await security.decrypt(respData);
    var respPayload = WiFiConfigPayload.fromBuffer(respRaw);

    if (respPayload.respGetStatus.staState.value == 0) {
      return ConnectionStatus(
          state: WifiConnectionState.Connected,
          deviceIp: respPayload.respGetStatus.connected.ip4Addr);
    } else if (respPayload.respGetStatus.staState.value == 1) {
      return ConnectionStatus(state: WifiConnectionState.Connecting);
    } else if (respPayload.respGetStatus.staState.value == 2) {
      return ConnectionStatus(state: WifiConnectionState.Disconnected);
    } else if (respPayload.respGetStatus.staState.value == 3) {
      if (respPayload.respGetStatus.failReason.value == 0) {
        return ConnectionStatus(
          state: WifiConnectionState.ConnectionFailed,
          failedReason: WifiConnectFailedReason.AuthError,
        );
      } else if (respPayload.respGetStatus.failReason.value == 1) {
        return ConnectionStatus(
          state: WifiConnectionState.ConnectionFailed,
          failedReason: WifiConnectFailedReason.NetworkNotFound,
        );
      }
      return ConnectionStatus(state: WifiConnectionState.ConnectionFailed);
    }
    return ConnectionStatus(
      state: WifiConnectionState.ConnectionFailed,
      failedReason: WifiConnectFailedReason.AuthError,
    );
  }

  Future<Uint8List> sendReceiveCustomData(Uint8List data,
      {int packageSize = 256}) async {
    var remainingData = data.length;
    var offset = 0;
    List<int> ret = [];

    while (remainingData > 0) {
      int end = (remainingData < packageSize) ? remainingData : packageSize;
      var needToSend = data.sublist(offset, offset + end);
      var encrypted = await security.encrypt(needToSend);
      var newData = await transport.sendReceive('custom-data', encrypted);

      if (newData.isNotEmpty) {
        var decrypted = await security.decrypt(newData);
        ret += List.from(decrypted);
      }

      offset += end;
      remainingData -= end;
    }
    return Uint8List.fromList(ret);
  }

  /// Decodes a binary BSSID and converts it to a hexadecimal string.
  ///
  /// This function takes a [binaryBssid] as input, which is a list of integers
  /// representing the BSSID in binary format. It then converts each integer to
  /// its hexadecimal representation, zero-padded to two digits, and joins them
  /// together with colons as separators.
  ///
  /// The function returns a hexadecimal string representation of the BSSID using
  /// colons as separators (e.g. "aa:05:cc:01:ee:ff"). It is required because the
  /// representation of the BSSID is like a MAC address. Callers are expected to
  /// pass exactly 6 bytes; this function does not validate that itself, see the
  /// length check in [scanResultResponse].
  String _decodeBssid(List<int> binaryBssid) =>
      binaryBssid.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');

  static final RegExp _bssidFormat =
      RegExp(r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$');

  /// Encodes a hexadecimal BSSID into its binary representation.
  ///
  /// This function takes a hexadecimal string as input, which is a string of hexadecimal
  /// digits separated by colons. It then splits the string into a list of hexadecimal
  /// digits and converts each digit back to its integer representation.
  ///
  /// The function returns a list of integers representing the binary BSSID.
  ///
  /// Unlike [_decodeBssid], this data can come from a caller, e.g. a technician
  /// typing or pasting a BSSID into a UI, so a malformed value is rejected with a
  /// clear [FormatException] instead of failing deep inside [int.parse] or,
  /// worse, silently sending a garbage BSSID to the device.
  List<int> _encodeBssid(String hexBssid) {
    if (!_bssidFormat.hasMatch(hexBssid)) {
      throw FormatException(
        'Invalid BSSID "$hexBssid": expected 6 colon-separated hex byte '
        'pairs, e.g. "aa:bb:cc:dd:ee:ff"',
        hexBssid,
      );
    }
    return hexBssid.split(':').map((e) => int.parse(e, radix: 16)).toList();
  }

  /// Field number of `auth` in `WiFiScanResult` (`wifi_scan.proto`).
  ///
  /// Written out instead of looked up by name, because field names are empty
  /// when an app is built with `protobuf.omit_field_names`.
  static const int _scanResultAuthField = 5;

  // Values of ESP-IDF's `wifi_auth_mode_t`, which the firmware reports as is:
  // https://github.com/espressif/esp-idf/blob/v5.4/components/esp_wifi/include/esp_wifi_types_generic.h#L81-L100
  // The numbering is stable: OWE is still 9 on master, where retired modes
  // keep their slot as placeholders and new ones are appended.

  /// `WIFI_AUTH_OPEN`: no encryption and no password.
  static const int _wifiAuthOpen = 0;

  /// `WIFI_AUTH_OWE`: Opportunistic Wireless Encryption, known as Wi-Fi
  /// Enhanced Open. The traffic is encrypted, but anyone can join without a
  /// password, so for [WifiAP.private] it is as open as `WIFI_AUTH_OPEN`.
  static const int _wifiAuthOwe = 9;

  /// The raw `wifi_auth_mode_t` value that the device reported for [entry].
  ///
  /// The firmware copies the Wi-Fi driver's auth mode into `auth` unchanged
  /// (0 to 15 in ESP-IDF v5.4), but the `WifiAuthMode` enum in
  /// `wifi_constants.proto` only names some of those values. protobuf does not
  /// set an enum field to a value it does not know: it keeps the varint in
  /// `unknownFields`, and `entry.auth` then reads as the default, `Open`. So
  /// the value is taken from `auth` when it is set, or else from the unknown
  /// fields. With neither, the device sent nothing, which in proto3 means 0.
  ///
  /// Comparing numbers instead of names also keeps this working when an app
  /// is built with `protobuf.omit_enum_names`, where every enum name is empty.
  static int _rawAuthMode(WiFiScanResult entry) {
    if (entry.hasAuth()) {
      return entry.auth.value;
    }
    final unknown = entry.unknownFields.getField(_scanResultAuthField);
    if (unknown == null || unknown.varints.isEmpty) {
      return _wifiAuthOpen;
    }
    // Like any singular field, the last occurrence on the wire wins.
    return unknown.varints.last.toInt();
  }

  /// Whether joining a network with the raw `wifi_auth_mode_t` [authMode]
  /// needs credentials, as reported in [WifiAP.private].
  ///
  /// Only Open and OWE do not. Every other mode is private, including values
  /// this package does not know yet: a lock shown on an open network costs
  /// little, while an app may skip the password prompt for a secured network
  /// reported as open.
  static bool _isPrivateAuthMode(int authMode) =>
      authMode != _wifiAuthOpen && authMode != _wifiAuthOwe;
}
