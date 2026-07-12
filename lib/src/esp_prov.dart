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
          private: entry.auth.toString() != 'Open'));
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
}
