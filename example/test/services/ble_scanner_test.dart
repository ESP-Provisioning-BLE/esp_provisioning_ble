import 'package:example/src/services/ble_scanner.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initial state', () {
    late BleScanner scanner;

    setUp(() {
      scanner = BleScanner();
    });

    tearDown(() {
      scanner.dispose();
    });

    test('devices list is empty', () {
      expect(scanner.devices, isEmpty);
    });

    test('adapter state is unknown before init', () {
      expect(scanner.adapterState, BluetoothAdapterState.unknown);
    });

    test('isAdapterReady is false before init', () {
      expect(scanner.isAdapterReady, isFalse);
    });

    test('isScanning is false initially', () {
      expect(scanner.isScanning, isFalse);
    });
  });

  group('dispose', () {
    test('does not throw when called on fresh instance', () {
      final scanner = BleScanner();
      expect(() => scanner.dispose(), returnsNormally);
    });

    // init() subscribes to FlutterBluePlus.adapterState which requires
    // a platform channel — not available in unit tests.
  });
}
