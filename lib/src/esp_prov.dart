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
import 'unexpected_message_type_exception.dart';

/// Result of [EspProv.establishSession].
///
/// When the handshake fails, the status does not say why it failed: it only
/// says whether the transport was still connected right after the failure
/// (see [keymismatch] and [disconnected]). Telling the causes apart, such as
/// a wrong proof of possession and other errors, is planned in
/// https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/37,
/// which will change when each value is returned.
enum EstablishSessionStatus {
  /// The session handshake finished and the device accepted it, so the other
  /// [EspProv] requests can be sent.
  connected,

  /// The transport reported that the device is not connected, before or
  /// during the handshake, or right after the handshake failed.
  ///
  /// A failed handshake is reported as [disconnected], whatever the cause,
  /// if the connection is already closed when [EspProv.establishSession]
  /// checks it. That includes a wrong proof of possession when the device
  /// closes the connection before that check.
  disconnected,

  /// The handshake failed while the device was still connected, whatever the
  /// cause.
  ///
  /// Despite its name, it does not mean that a key mismatch was detected.
  /// [EspProv.establishSession] returns it for any error raised during the
  /// handshake while [ProvTransport.checkConnect] still reports a
  /// connection: a wrong proof of possession with [Security1], a response
  /// that is not a valid Security 0 response with [Security0], an empty or
  /// undecodable response, or an error thrown by the transport. A wrong
  /// proof of possession can also come back as [disconnected] if the device
  /// closes the connection first.
  keymismatch,
}

UnexpectedMessageTypeException _unexpectedScanMessage(
    WiFiScanMsgType expected, WiFiScanPayload received) {
  return UnexpectedMessageTypeException(
    expectedType: expected.name,
    expectedValue: expected.value,
    actualType: received.msg.name,
    actualValue: received.msg.value,
    payload: received.toString(),
  );
}

/// Client for the provisioning service of an ESP32 device.
///
/// It implements the client side of Espressif's unified provisioning
/// protocol: it builds the protobuf requests for the session (`prov-session`),
/// Wi-Fi scan (`prov-scan`), Wi-Fi configuration (`prov-config`) and custom
/// data (`custom-data`) endpoints, protects them with [security] and sends
/// them through [transport].
///
/// The transport must already be connected to the device: [EspProv] never
/// calls [ProvTransport.connect]. Call [establishSession] first and use the
/// other requests only after it returns [EstablishSessionStatus.connected].
///
/// Unless a method says otherwise, errors thrown by [transport] or [security],
/// and responses that cannot be decoded as the expected protobuf message,
/// are not caught and reach the caller.
class EspProv {
  /// The transport that carries every request to the device.
  ProvTransport transport;

  /// The security scheme that runs the session handshake and protects the
  /// requests. It must match the security scheme of the device firmware.
  ProvSecurity security;

  /// Creates a provisioning client that talks to the device through
  /// [transport] using the security scheme [security].
  EspProv({required this.transport, required this.security});

  /// Runs the session handshake of [security] with the device.
  ///
  /// It starts by passing an empty `SessionData` to
  /// [ProvSecurity.securitySession], sends each request it returns to the
  /// `prov-session` endpoint and passes the decoded response back, until
  /// [ProvSecurity.securitySession] returns `null`. Before each round it
  /// checks [ProvTransport.checkConnect].
  ///
  /// Returns:
  ///
  /// - [EstablishSessionStatus.connected] when the handshake finished;
  /// - [EstablishSessionStatus.disconnected] when the device is not
  ///   connected, or an error happened and the device is no longer
  ///   connected;
  /// - [EstablishSessionStatus.keymismatch] when an error happened while the
  ///   device is still connected, including an empty response.
  ///
  /// It never throws: errors are turned into one of the statuses above. The
  /// error itself is not inspected. After an error, the status depends only
  /// on [ProvTransport.checkConnect], so the same cause can give either
  /// status: a wrong proof of possession gives
  /// [EstablishSessionStatus.keymismatch] if the device is still connected
  /// at that moment, and [EstablishSessionStatus.disconnected] if it has
  /// already closed the connection. This is planned to change in
  /// https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble/issues/37.
  ///
  /// Once the session is established, calling it again returns
  /// [EstablishSessionStatus.connected] without repeating the handshake, as
  /// long as the transport is still connected. [Security0] and [Security1]
  /// do not reset after a failed handshake, so to try again create a new
  /// security object and assign it to [security] (or create a new
  /// [EspProv]).
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

  /// Disconnects the device by calling [ProvTransport.disconnect].
  ///
  /// The result of [ProvTransport.disconnect] is ignored, and [security] is
  /// left as it is.
  Future<void> dispose() async {
    await transport.disconnect();
  }

  /// Asks the device to scan for Wi-Fi networks and returns the access
  /// points it found.
  ///
  /// It is the same as [scan] with its default arguments: a blocking active
  /// scan.
  ///
  /// Throws an [UnexpectedMessageTypeException] if the device answers a scan
  /// request with a message of another type.
  Future<List<WifiAP>> startScanWiFi() async {
    return await scan();
  }

  /// Decrypts and decodes [data], the device's response to a scan start
  /// command.
  ///
  /// This is a building block of [startScanRequest]; most apps use [scan] or
  /// [startScanWiFi] instead.
  ///
  /// Throws an [UnexpectedMessageTypeException] if the message is not a scan
  /// start response (`TypeRespScanStart`).
  Future<WiFiScanPayload> startScanResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStart) {
      throw _unexpectedScanMessage(
          WiFiScanMsgType.TypeRespScanStart, respPayload);
    }
    return respPayload;
  }

  /// Sends a scan start command to the `prov-scan` endpoint and returns the
  /// decoded response.
  ///
  /// The arguments are passed to the device as they are. With ESP-IDF's
  /// provisioning manager:
  ///
  /// - [blocking]: when `true`, the device answers only after the scan has
  ///   finished; when `false`, it answers as soon as the scan has started.
  /// - [passive]: when `true`, the device runs a passive scan instead of an
  ///   active one.
  /// - [groupChannels]: how many channels the device scans in one go
  ///   (`0` scans all of them at once).
  /// - [periodMs]: scan time on each channel, in milliseconds. The manager
  ///   ignores it when the firmware is built with Bluetooth enabled.
  ///
  /// Use [scanStatusRequest] to know when the scan has finished and how many
  /// results there are, and [scanResultRequest] to fetch them.
  ///
  /// Throws an [UnexpectedMessageTypeException] if the response is not a scan
  /// start response.
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

  /// Decrypts and decodes [data], the device's response to a scan status
  /// command.
  ///
  /// This is a building block of [scanStatusRequest].
  ///
  /// Throws an [UnexpectedMessageTypeException] if the message is not a scan
  /// status response (`TypeRespScanStatus`).
  Future<WiFiScanPayload> scanStatusResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStatus) {
      throw _unexpectedScanMessage(
          WiFiScanMsgType.TypeRespScanStatus, respPayload);
    }
    return respPayload;
  }

  /// Sends a scan status command to the `prov-scan` endpoint and returns the
  /// decoded response.
  ///
  /// Its `respScanStatus` tells whether the scan has finished
  /// (`scanFinished`) and how many access points the device has stored
  /// (`resultCount`).
  ///
  /// Throws an [UnexpectedMessageTypeException] if the response is not a scan
  /// status response.
  Future<WiFiScanPayload> scanStatusRequest() async {
    WiFiScanPayload payload = WiFiScanPayload();
    payload.msg = WiFiScanMsgType.TypeCmdScanStatus;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-scan', reqData);
    return await scanStatusResponse(respData);
  }

  /// Asks the `prov-scan` endpoint for [count] scan results starting at
  /// [startIndex] and returns them as [WifiAP] objects.
  ///
  /// The indices refer to the results stored on the device; see
  /// [scanStatusRequest] for how many there are. The results are converted
  /// as described in [scanResultResponse].
  ///
  /// Throws an [UnexpectedMessageTypeException] if the response is not a scan
  /// result response.
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

  /// Decrypts and decodes [data], the device's response to a scan result
  /// command, and converts each entry into a [WifiAP].
  ///
  /// For each entry, [WifiAP.ssid] is the SSID decoded as UTF-8,
  /// [WifiAP.rssi] the reported signal strength, [WifiAP.bssid] the BSSID in
  /// `aa:bb:cc:dd:ee:ff` form (or `null` if the device did not send exactly
  /// 6 bytes) and [WifiAP.private] whether the auth mode needs credentials.
  /// [WifiAP.active] keeps its default, `false`.
  ///
  /// This is a building block of [scanResultRequest].
  ///
  /// Throws an [UnexpectedMessageTypeException] if the message is not a scan
  /// result response (`TypeRespScanResult`), and a [FormatException] if an
  /// SSID is not valid UTF-8.
  Future<List<WifiAP>> scanResultResponse(Uint8List data) async {
    var respPayload = WiFiScanPayload.fromBuffer(await security.decrypt(data));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanResult) {
      throw _unexpectedScanMessage(
          WiFiScanMsgType.TypeRespScanResult, respPayload);
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

  /// Runs a whole Wi-Fi scan on the device and returns the access points it
  /// found.
  ///
  /// It sends [startScanRequest] with the given arguments, reads the number
  /// of results with [scanStatusRequest] and fetches them with
  /// [scanResultRequest], at most 4 per request.
  ///
  /// It does not wait for the scan to finish: with [blocking] set to `false`
  /// the device answers as soon as the scan has started, so the list may be
  /// empty or incomplete.
  ///
  /// Throws an [UnexpectedMessageTypeException] if the device answers any of
  /// these requests with a message of another type.
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

  /// Sends the Wi-Fi credentials to the `prov-config` endpoint.
  ///
  /// [ssid] and [password] are sent UTF-8 encoded. ESP-IDF's provisioning
  /// manager accepts an SSID of up to 32 bytes and a password of up to 63
  /// bytes. The device stores the credentials but does not use them until
  /// [applyWifiConfig] is called.
  ///
  /// [bssid], in `aa:bb:cc:dd:ee:ff` form, is sent as the BSSID of the access
  /// point to join. Whether the device uses it depends on its firmware:
  /// ESP-IDF's stock provisioning manager (checked on v5.4 and v5.5)
  /// validates its length and then drops it, so the device joins the network
  /// by SSID. Only a firmware that applies the BSSID itself joins that
  /// specific access point.
  ///
  /// Returns `false` if the device answers with an error status, for example
  /// when the SSID or the password is too long, and `true` otherwise.
  ///
  /// Throws a [FormatException], before anything is sent, if [bssid] is not
  /// six colon-separated pairs of hexadecimal digits.
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

  /// Tells the device, through the `prov-config` endpoint, to connect to the
  /// network sent with [sendWifiConfig].
  ///
  /// Returns `false` if the device answers with an error status, and `true`
  /// otherwise. `true` only means that the device started connecting: use
  /// [getStatus] to follow the result.
  ///
  /// ESP-IDF's provisioning manager answers with an error when no
  /// credentials were sent first, and also once the device has received
  /// credentials, until the firmware resets the provisioning state after a
  /// failure (with `wifi_prov_mgr_reset_sm_state_on_failure()`). So after a
  /// failed connection, new credentials are only applied if the firmware
  /// does that reset; reconnecting over BLE does not.
  Future<bool> applyWifiConfig() async {
    var payload = WiFiConfigPayload();
    payload.msg = WiFiConfigMsgType.TypeCmdApplyConfig;
    var reqData = await security.encrypt(payload.writeToBuffer());
    var respData = await transport.sendReceive('prov-config', reqData);
    var respRaw = await security.decrypt(respData);
    var respPayload = WiFiConfigPayload.fromBuffer(respRaw);
    return (respPayload.respApplyConfig.status == Status.Success);
  }

  /// Asks the `prov-config` endpoint for the state of the device's Wi-Fi
  /// connection.
  ///
  /// The returned [ConnectionStatus] has:
  ///
  /// - [WifiConnectionState.Connected] and the device's IPv4 address in
  ///   [ConnectionStatus.deviceIp];
  /// - [WifiConnectionState.Connecting] or [WifiConnectionState.Disconnected]
  ///   with no other data;
  /// - [WifiConnectionState.ConnectionFailed] with
  ///   [WifiConnectFailedReason.NetworkNotFound] if the device reports that
  ///   the network was not found, or [WifiConnectFailedReason.AuthError]
  ///   otherwise.
  ///
  /// Poll it after [applyWifiConfig] until the state is no longer
  /// [WifiConnectionState.Connecting]. ESP-IDF's provisioning manager stops
  /// the provisioning service once it has reported
  /// [WifiConnectionState.Connected], so later requests may fail.
  ///
  /// This package does not retry a failed connection and does not follow
  /// the device's retries: each call returns what the device reports at that
  /// moment. The firmware decides whether the device retries. While it does,
  /// ESP-IDF's provisioning manager reports [WifiConnectionState.Connecting]
  /// (the number of remaining attempts is not exposed), and a firmware that
  /// keeps retrying after reporting [WifiConnectionState.ConnectionFailed]
  /// can still connect later. See "Wi-Fi connection retries" in the README.
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

  /// Sends [data] to the `custom-data` endpoint and returns what the device
  /// answers.
  ///
  /// [data] is split into chunks of at most [packageSize] bytes, which must
  /// be greater than zero. Each chunk is encrypted with [security] (with
  /// [Security0] it travels in the clear) and sent as a separate request;
  /// the non-empty responses are decrypted and concatenated in order. An
  /// empty [data] sends nothing and returns an empty [Uint8List].
  ///
  /// The firmware must provide an endpoint named `custom-data`, which with
  /// ESP-IDF's provisioning manager means creating it with
  /// `wifi_prov_mgr_endpoint_create("custom-data")` and registering a handler
  /// for it. Send custom data after [establishSession] and before the Wi-Fi
  /// configuration completes, because the manager removes all endpoints once
  /// provisioning ends.
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
