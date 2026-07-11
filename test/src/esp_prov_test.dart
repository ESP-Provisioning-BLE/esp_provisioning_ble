import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:esp_provisioning_ble/src/esp_prov.dart';
import 'package:esp_provisioning_ble/src/transport.dart';
import 'package:esp_provisioning_ble/src/security.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_scan.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_config.pb.dart';
import 'package:esp_provisioning_ble/src/connection_models.dart';
import 'package:esp_provisioning_ble/src/protos/generated/constants.pbenum.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_constants.pb.dart'
    as proto;

class MockProvTransport extends Mock implements ProvTransport {}

class MockProvSecurity extends Mock implements ProvSecurity {}

// Protobuf response builders

Uint8List _scanStartResp() => Uint8List.fromList(
      (WiFiScanPayload()
            ..msg = WiFiScanMsgType.TypeRespScanStart
            ..respScanStart = RespScanStart())
          .writeToBuffer(),
    );

Uint8List _scanStatusResp(int resultCount) => Uint8List.fromList(
      (WiFiScanPayload()
            ..msg = WiFiScanMsgType.TypeRespScanStatus
            ..respScanStatus = (RespScanStatus()..resultCount = resultCount))
          .writeToBuffer(),
    );

Uint8List _scanResultResp(List<WiFiScanResult> entries) {
  final payload = WiFiScanPayload()
    ..msg = WiFiScanMsgType.TypeRespScanResult
    ..respScanResult = (RespScanResult()..entries.addAll(entries));
  return Uint8List.fromList(payload.writeToBuffer());
}

Uint8List _wifiConfigResp(Status status) => Uint8List.fromList(
      (WiFiConfigPayload()
            ..msg = WiFiConfigMsgType.TypeRespSetConfig
            ..respSetConfig = (RespSetConfig()..status = status))
          .writeToBuffer(),
    );

Uint8List _applyConfigResp(Status status) => Uint8List.fromList(
      (WiFiConfigPayload()
            ..msg = WiFiConfigMsgType.TypeRespApplyConfig
            ..respApplyConfig = (RespApplyConfig()..status = status))
          .writeToBuffer(),
    );

Uint8List _getStatusResp(
  proto.WifiStationState state, {
  String? ip4Addr,
  proto.WifiConnectFailedReason? failReason,
}) {
  final getStatus = RespGetStatus()..staState = state;
  if (ip4Addr != null) {
    getStatus.connected = proto.WifiConnectedState()..ip4Addr = ip4Addr;
  }
  if (failReason != null) {
    getStatus.failReason = failReason;
  }
  return Uint8List.fromList(
    (WiFiConfigPayload()
          ..msg = WiFiConfigMsgType.TypeRespGetStatus
          ..respGetStatus = getStatus)
        .writeToBuffer(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  late MockProvTransport transport;
  late MockProvSecurity security;
  late EspProv espProv;

  setUp(() {
    transport = MockProvTransport();
    security = MockProvSecurity();
    espProv = EspProv(transport: transport, security: security);

    // Default: encrypt is a passthrough so requests remain readable.
    when(() => security.encrypt(any())).thenAnswer(
      (inv) async => inv.positionalArguments.first as Uint8List,
    );
    // Default: sendReceive returns a non-empty byte so no "empty response" throws.
    when(() => transport.sendReceive(any(), any()))
        .thenAnswer((_) async => Uint8List.fromList([0]));
  });

  group('startScanWiFi', () {
    void stubDecryptSequence(List<Uint8List> responses) {
      var call = 0;
      when(() => security.decrypt(any())).thenAnswer((_) async {
        if (call < responses.length) return responses[call++];
        throw StateError('Unexpected decrypt call ${call + 1}');
      });
    }

    test('returns empty list when scan result count is zero', () async {
      stubDecryptSequence([_scanStartResp(), _scanStatusResp(0)]);

      final result = await espProv.startScanWiFi();
      expect(result, isEmpty);
    });

    test('parses AP entries into WifiAP objects', () async {
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('HomeWifi')
        ..rssi = -55
        ..auth = proto.WifiAuthMode.WPA2_PSK;

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(1),
        _scanResultResp([entry]),
      ]);

      final result = await espProv.startScanWiFi();

      expect(result, hasLength(1));
      expect(result.first.ssid, equals('HomeWifi'));
      expect(result.first.rssi, equals(-55));
      expect(result.first.private, isTrue);
      expect(result.first.bssid, isNull);
    });

    test('decodes a present bssid into a colon-separated hex string',
        () async {
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('HomeWifi')
        ..rssi = -55
        ..bssid = [0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff]
        ..auth = proto.WifiAuthMode.WPA2_PSK;

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(1),
        _scanResultResp([entry]),
      ]);

      final result = await espProv.startScanWiFi();
      expect(result.first.bssid, equals('aa:bb:cc:dd:ee:ff'));
    });

    test('zero-pads bssid bytes below 0x10 instead of dropping the digit',
        () async {
      // Regression test: int.toRadixString(16) does not zero-pad, so a byte
      // like 0x05 used to decode to "5" instead of "05", producing a bssid
      // string that was not valid MAC notation.
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('HomeWifi')
        ..rssi = -55
        ..bssid = [0xaa, 0x05, 0xcc, 0x00, 0xee, 0xff]
        ..auth = proto.WifiAuthMode.WPA2_PSK;

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(1),
        _scanResultResp([entry]),
      ]);

      final result = await espProv.startScanWiFi();
      expect(result.first.bssid, equals('aa:05:cc:00:ee:ff'));
    });

    test('treats a bssid of the wrong length as absent instead of garbage',
        () async {
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('HomeWifi')
        ..rssi = -55
        ..bssid = [0xaa, 0xbb, 0xcc] // malformed: not 6 bytes
        ..auth = proto.WifiAuthMode.WPA2_PSK;

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(1),
        _scanResultResp([entry]),
      ]);

      final result = await espProv.startScanWiFi();
      expect(result.first.bssid, isNull);
    });

    test('marks open network as not private', () async {
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('CafeWifi')
        ..rssi = -70
        ..auth = proto.WifiAuthMode.Open;

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(1),
        _scanResultResp([entry]),
      ]);

      final result = await espProv.startScanWiFi();
      expect(result.first.private, isFalse);
    });

    test('fetches results in batches of 4 when resultCount > 4', () async {
      final entries = List.generate(
        5,
        (i) => WiFiScanResult()
          ..ssid = utf8.encode('AP$i')
          ..rssi = -50 - i * 5
          ..auth = proto.WifiAuthMode.WPA2_PSK,
      );

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(5),
        _scanResultResp(entries.sublist(0, 4)), // batch 1
        _scanResultResp(entries.sublist(4)), // batch 2
      ]);

      final result = await espProv.startScanWiFi();

      expect(result, hasLength(5));
      expect(
        result.map((ap) => ap.ssid).toList(),
        equals(['AP0', 'AP1', 'AP2', 'AP3', 'AP4']),
      );
    });

    test('sends requests to prov-scan endpoint', () async {
      stubDecryptSequence([_scanStartResp(), _scanStatusResp(0)]);

      await espProv.startScanWiFi();

      verify(() => transport.sendReceive('prov-scan', any())).called(2);
    });
  });

  group('sendWifiConfig', () {
    void stubConfigResponse({Status status = Status.Success}) {
      when(() => security.decrypt(any())).thenAnswer(
        (_) async => _wifiConfigResp(status),
      );
    }

    test('serialises SSID and password into the protobuf request', () async {
      stubConfigResponse();

      await espProv.sendWifiConfig(ssid: 'MySSID', password: 'SecretPass');

      final captured = verify(() => security.encrypt(captureAny())).captured;
      final payload = WiFiConfigPayload.fromBuffer(captured.first as Uint8List);
      expect(utf8.decode(payload.cmdSetConfig.ssid), equals('MySSID'));
      expect(
          utf8.decode(payload.cmdSetConfig.passphrase), equals('SecretPass'));
    });

    test('sends request to prov-config endpoint', () async {
      stubConfigResponse();
      await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass');
      verify(() => transport.sendReceive('prov-config', any())).called(1);
    });

    test('returns true when device responds with Success', () async {
      stubConfigResponse(status: Status.Success);
      expect(
          await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass'), isTrue);
    });

    test('returns false when device responds with a non-Success status',
        () async {
      stubConfigResponse(status: Status.InvalidArgument);
      expect(await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass'),
          isFalse);
    });

    test('encodes bssid into the protobuf request when provided', () async {
      stubConfigResponse();

      await espProv.sendWifiConfig(
        ssid: 'MySSID',
        password: 'SecretPass',
        bssid: 'aa:05:cc:00:ee:ff',
      );

      final captured = verify(() => security.encrypt(captureAny())).captured;
      final payload = WiFiConfigPayload.fromBuffer(captured.first as Uint8List);
      expect(
        payload.cmdSetConfig.bssid,
        equals([0xaa, 0x05, 0xcc, 0x00, 0xee, 0xff]),
      );
    });

    test('omits bssid from the protobuf request when not provided', () async {
      stubConfigResponse();

      await espProv.sendWifiConfig(ssid: 'MySSID', password: 'SecretPass');

      final captured = verify(() => security.encrypt(captureAny())).captured;
      final payload = WiFiConfigPayload.fromBuffer(captured.first as Uint8List);
      expect(payload.cmdSetConfig.bssid, isEmpty);
    });

    test(
        'rejects a malformed bssid with a FormatException without hitting '
        'the transport', () async {
      expect(
        espProv.sendWifiConfig(
          ssid: 'MySSID',
          password: 'SecretPass',
          bssid: 'not-a-bssid',
        ),
        throwsFormatException,
      );

      verifyNever(() => transport.sendReceive(any(), any()));
    });
  });

  group('applyWifiConfig', () {
    void stubApplyResponse({Status status = Status.Success}) {
      when(() => security.decrypt(any())).thenAnswer(
        (_) async => _applyConfigResp(status),
      );
    }

    test('sends request to prov-config endpoint', () async {
      stubApplyResponse();
      await espProv.applyWifiConfig();
      verify(() => transport.sendReceive('prov-config', any())).called(1);
    });

    test('returns true when device responds with Success', () async {
      stubApplyResponse(status: Status.Success);
      expect(await espProv.applyWifiConfig(), isTrue);
    });

    test('returns false when device responds with a non-Success status',
        () async {
      stubApplyResponse(status: Status.InvalidArgument);
      expect(await espProv.applyWifiConfig(), isFalse);
    });
  });

  group('getStatus', () {
    test('returns Connected with device IP', () async {
      when(() => security.decrypt(any())).thenAnswer((_) async =>
          _getStatusResp(proto.WifiStationState.Connected,
              ip4Addr: '192.168.1.1'));

      final result = await espProv.getStatus();

      expect(result.state, equals(WifiConnectionState.Connected));
      expect(result.deviceIp, equals('192.168.1.1'));
    });

    test('returns Connecting', () async {
      when(() => security.decrypt(any())).thenAnswer(
          (_) async => _getStatusResp(proto.WifiStationState.Connecting));

      final result = await espProv.getStatus();
      expect(result.state, equals(WifiConnectionState.Connecting));
    });

    test('returns Disconnected', () async {
      when(() => security.decrypt(any())).thenAnswer(
          (_) async => _getStatusResp(proto.WifiStationState.Disconnected));

      final result = await espProv.getStatus();
      expect(result.state, equals(WifiConnectionState.Disconnected));
    });

    test('returns ConnectionFailed with AuthError', () async {
      when(() => security.decrypt(any())).thenAnswer((_) async =>
          _getStatusResp(proto.WifiStationState.ConnectionFailed,
              failReason: proto.WifiConnectFailedReason.AuthError));

      final result = await espProv.getStatus();
      expect(result.state, equals(WifiConnectionState.ConnectionFailed));
      expect(result.failedReason, equals(WifiConnectFailedReason.AuthError));
    });

    test('returns ConnectionFailed with NetworkNotFound', () async {
      when(() => security.decrypt(any())).thenAnswer((_) async =>
          _getStatusResp(proto.WifiStationState.ConnectionFailed,
              failReason: proto.WifiConnectFailedReason.NetworkNotFound));

      final result = await espProv.getStatus();
      expect(result.state, equals(WifiConnectionState.ConnectionFailed));
      expect(
          result.failedReason, equals(WifiConnectFailedReason.NetworkNotFound));
    });
  });

  group('sendReceiveCustomData', () {
    setUp(() {
      when(() => security.decrypt(any())).thenAnswer(
        (inv) async => inv.positionalArguments.first as Uint8List,
      );
    });

    test('sends data to custom-data endpoint and returns decrypted response',
        () async {
      when(() => transport.sendReceive('custom-data', any()))
          .thenAnswer((_) async => Uint8List.fromList([7, 8, 9]));

      final result = await espProv.sendReceiveCustomData(
        Uint8List.fromList([1, 2, 3]),
      );

      expect(result, equals(Uint8List.fromList([7, 8, 9])));
      verify(() => transport.sendReceive('custom-data', any())).called(1);
    });

    test('splits data into chunks and accumulates responses', () async {
      var call = 0;
      when(() => transport.sendReceive('custom-data', any()))
          .thenAnswer((_) async => Uint8List.fromList([(call++ + 1) * 10]));

      final result = await espProv.sendReceiveCustomData(
        Uint8List.fromList([1, 2, 3, 4, 5]),
        packageSize: 2,
      );

      expect(result, equals(Uint8List.fromList([10, 20, 30])));
      verify(() => transport.sendReceive('custom-data', any())).called(3);
    });

    test('skips empty transport responses', () async {
      when(() => transport.sendReceive('custom-data', any()))
          .thenAnswer((_) async => Uint8List(0));

      final result = await espProv.sendReceiveCustomData(
        Uint8List.fromList([1, 2, 3]),
      );

      expect(result, isEmpty);
      verifyNever(() => security.decrypt(any()));
    });
  });
}
