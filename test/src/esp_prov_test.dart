import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:esp_provisioning_ble/src/esp_prov.dart';
import 'package:esp_provisioning_ble/src/transport.dart';
import 'package:esp_provisioning_ble/src/security.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_scan.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_config.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/constants.pbenum.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_constants.pbenum.dart';

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
        ..auth = WifiAuthMode.WPA2_PSK;

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
    });

    test('marks open network as not private', () async {
      final entry = WiFiScanResult()
        ..ssid = utf8.encode('CafeWifi')
        ..rssi = -70
        ..auth = WifiAuthMode.Open;

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
          ..auth = WifiAuthMode.WPA2_PSK,
      );

      stubDecryptSequence([
        _scanStartResp(),
        _scanStatusResp(5),
        _scanResultResp(entries.sublist(0, 4)), // batch 1
        _scanResultResp(entries.sublist(4)),    // batch 2
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
      expect(utf8.decode(payload.cmdSetConfig.passphrase), equals('SecretPass'));
    });

    test('sends request to prov-config endpoint', () async {
      stubConfigResponse();
      await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass');
      verify(() => transport.sendReceive('prov-config', any())).called(1);
    });

    test('returns true when device responds with Success', () async {
      stubConfigResponse(status: Status.Success);
      expect(await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass'), isTrue);
    });

    test('returns false when device responds with a non-Success status', () async {
      stubConfigResponse(status: Status.InvalidArgument);
      expect(await espProv.sendWifiConfig(ssid: 'SSID', password: 'pass'), isFalse);
    });
  });
}
