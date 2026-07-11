import 'dart:convert';
import 'dart:typed_data';

import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:example/src/services/provisioning_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProvTransport extends Mock implements ProvTransport {}

class MockEspProv extends Mock implements EspProv {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

void main() {
  late MockProvTransport mockTransport;
  late MockEspProv mockProv;
  late MockBluetoothDevice mockDevice;
  late ProvisioningService service;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockTransport = MockProvTransport();
    mockProv = MockEspProv();
    mockDevice = MockBluetoothDevice();

    // Default stub so tearDown's dispose doesn't throw.
    when(() => mockProv.dispose()).thenAnswer((_) async {});

    service = ProvisioningService(
      createTransport: (_) => mockTransport,
      createProv: ({required transport, required security}) => mockProv,
    );
  });

  tearDown(() async {
    await service.disconnect();
  });

  group('connectAndEstablishSession', () {
    test('reaches sessionReady on successful connection', () async {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.connected);

      final states = <ProvState>[];
      service.addListener(() => states.add(service.state));

      await service.connectAndEstablishSession(mockDevice, 'abcd1234');

      expect(service.state, ProvState.sessionReady);
      expect(states, [
        ProvState.connecting,
        ProvState.sessionEstablishing,
        ProvState.sessionReady,
      ]);
    });

    test('reaches failed when transport connect fails', () async {
      when(() => mockTransport.connect()).thenAnswer((_) async => false);

      await service.connectAndEstablishSession(mockDevice, 'abcd1234');

      expect(service.state, ProvState.failed);
      expect(service.errorMessage, 'Failed to connect to device');
    });

    test('reaches disconnected on session disconnect', () async {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.disconnected);

      await service.connectAndEstablishSession(mockDevice, 'abcd1234');

      expect(service.state, ProvState.disconnected);
      expect(
        service.errorMessage,
        'Device disconnected during session establishment',
      );
    });

    test('reaches keyMismatch on key mismatch', () async {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.keymismatch);

      await service.connectAndEstablishSession(mockDevice, 'wrong');

      expect(service.state, ProvState.keyMismatch);
      expect(service.errorMessage, 'Wrong proof-of-possession (key mismatch)');
    });
  });

  group('scanWifi', () {
    setUp(() {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.connected);
    });

    test('populates wifiNetworks on success', () async {
      final networks = [
        const WifiAP(ssid: 'Home', rssi: -40),
        const WifiAP(ssid: 'Office', rssi: -65, private: false),
      ];
      when(() => mockProv.startScanWiFi()).thenAnswer((_) async => networks);

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.scanWifi();

      expect(service.state, ProvState.wifiReady);
      expect(service.wifiNetworks, networks);
    });

    test('reaches failed when scan throws', () async {
      when(() => mockProv.startScanWiFi()).thenThrow(Exception('timeout'));

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.scanWifi();

      expect(service.state, ProvState.failed);
      expect(service.errorMessage, 'Failed to scan WiFi networks');
    });
  });

  group('sendConfig', () {
    setUp(() {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.connected);
    });

    test('reaches success when poll returns Connected', () async {
      when(
        () => mockProv.sendWifiConfig(
          ssid: any(named: 'ssid'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockProv.applyWifiConfig()).thenAnswer((_) async => true);
      when(() => mockProv.getStatus()).thenAnswer(
        (_) async => ConnectionStatus(
          state: WifiConnectionState.Connected,
          deviceIp: '192.168.1.100',
        ),
      );

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.sendConfig('Home', 'pass123');

      // Wait for the Timer.periodic to fire
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(service.state, ProvState.success);
      expect(service.connectionStatus?.deviceIp, '192.168.1.100');
    });

    test('sends custom data before wifi config', () async {
      final customResponse = Uint8List.fromList(utf8.encode('ok'));
      when(
        () => mockProv.sendReceiveCustomData(any()),
      ).thenAnswer((_) async => customResponse);
      when(
        () => mockProv.sendWifiConfig(
          ssid: any(named: 'ssid'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockProv.applyWifiConfig()).thenAnswer((_) async => true);
      when(() => mockProv.getStatus()).thenAnswer(
        (_) async => ConnectionStatus(
          state: WifiConnectionState.Connected,
          deviceIp: '192.168.1.100',
        ),
      );

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.sendConfig('Home', 'pass', customData: 'Hello');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      verify(() => mockProv.sendReceiveCustomData(any())).called(1);
      expect(service.state, ProvState.success);
    });

    test('reaches failed with auth error message on AuthError', () async {
      when(
        () => mockProv.sendWifiConfig(
          ssid: any(named: 'ssid'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockProv.applyWifiConfig()).thenAnswer((_) async => true);
      when(() => mockProv.getStatus()).thenAnswer(
        (_) async => ConnectionStatus(
          state: WifiConnectionState.ConnectionFailed,
          failedReason: WifiConnectFailedReason.AuthError,
        ),
      );

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.sendConfig('Home', 'wrong');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(service.state, ProvState.failed);
      expect(
        service.errorMessage,
        'Authentication error (wrong WiFi password)',
      );
    });

    test('reaches failed with network not found message', () async {
      when(
        () => mockProv.sendWifiConfig(
          ssid: any(named: 'ssid'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockProv.applyWifiConfig()).thenAnswer((_) async => true);
      when(() => mockProv.getStatus()).thenAnswer(
        (_) async => ConnectionStatus(
          state: WifiConnectionState.ConnectionFailed,
          failedReason: WifiConnectFailedReason.NetworkNotFound,
        ),
      );

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.sendConfig('Ghost', 'pass');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(service.state, ProvState.failed);
      expect(service.errorMessage, 'Network not found');
    });

    test('reaches failed when sendWifiConfig throws', () async {
      when(
        () => mockProv.sendWifiConfig(
          ssid: any(named: 'ssid'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('BLE error'));

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.sendConfig('Home', 'pass');

      expect(service.state, ProvState.failed);
      expect(service.errorMessage, 'Failed to send WiFi configuration');
    });
  });

  group('disconnect', () {
    test('resets state to idle and clears data', () async {
      when(() => mockTransport.connect()).thenAnswer((_) async => true);
      when(
        () => mockProv.establishSession(),
      ).thenAnswer((_) async => EstablishSessionStatus.connected);
      when(
        () => mockProv.startScanWiFi(),
      ).thenAnswer((_) async => [const WifiAP(ssid: 'Test', rssi: -50)]);
      when(() => mockProv.dispose()).thenAnswer((_) async {});

      await service.connectAndEstablishSession(mockDevice, 'pop');
      await service.scanWifi();

      expect(service.wifiNetworks, isNotEmpty);

      await service.disconnect();

      expect(service.state, ProvState.idle);
      expect(service.wifiNetworks, isEmpty);
      expect(service.connectionStatus, isNull);
      expect(service.errorMessage, isNull);
    });
  });
}
