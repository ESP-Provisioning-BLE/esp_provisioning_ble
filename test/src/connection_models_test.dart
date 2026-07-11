import 'package:flutter_test/flutter_test.dart';
import 'package:esp_provisioning_ble/src/connection_models.dart';

void main() {
  group('WifiAP.compareTo', () {
    test('returns -1 when this AP has higher RSSI than other', () {
      const strong = WifiAP(ssid: 'StrongAP', rssi: -40);
      const weak = WifiAP(ssid: 'WeakAP', rssi: -80);
      expect(strong.compareTo(weak), equals(-1));
    });

    test('returns 1 when this AP has lower RSSI than other', () {
      const strong = WifiAP(ssid: 'StrongAP', rssi: -40);
      const weak = WifiAP(ssid: 'WeakAP', rssi: -80);
      expect(weak.compareTo(strong), equals(1));
    });

    test('returns 0 when both APs have equal RSSI', () {
      const ap1 = WifiAP(ssid: 'AP1', rssi: -60);
      const ap2 = WifiAP(ssid: 'AP2', rssi: -60);
      expect(ap1.compareTo(ap2), equals(0));
    });

    test('returns 0 for equal RSSI at very negative values', () {
      const ap1 = WifiAP(ssid: 'AP1', rssi: -100);
      const ap2 = WifiAP(ssid: 'AP2', rssi: -100);
      expect(ap1.compareTo(ap2), equals(0));
    });

    test('sorting a list by compareTo produces descending RSSI order', () {
      final aps = [
        const WifiAP(ssid: 'C', rssi: -70),
        const WifiAP(ssid: 'A', rssi: -40),
        const WifiAP(ssid: 'B', rssi: -55),
      ];
      aps.sort((a, b) => a.compareTo(b));
      expect(aps.map((ap) => ap.ssid).toList(), equals(['A', 'B', 'C']));
    });
  });

  group('WifiAP fields', () {
    test('stores ssid and rssi correctly', () {
      const ap = WifiAP(ssid: 'MyNetwork', rssi: -65);
      expect(ap.ssid, equals('MyNetwork'));
      expect(ap.rssi, equals(-65));
    });

    test('active defaults to false', () {
      const ap = WifiAP(ssid: 'Net', rssi: -50);
      expect(ap.active, isFalse);
    });

    test('private defaults to true', () {
      const ap = WifiAP(ssid: 'Net', rssi: -50);
      expect(ap.private, isTrue);
    });

    test('explicit active and private values are stored', () {
      const ap = WifiAP(ssid: 'Open', rssi: -50, active: true, private: false);
      expect(ap.active, isTrue);
      expect(ap.private, isFalse);
    });
  });

  group('WifiAP equality', () {
    test('two APs with the same bssid are equal regardless of other fields',
        () {
      const ap1 = WifiAP(bssid: 'aa:bb:cc:dd:ee:ff', ssid: 'Net', rssi: -50);
      const ap2 = WifiAP(bssid: 'aa:bb:cc:dd:ee:ff', ssid: 'Other', rssi: -80);
      expect(ap1, equals(ap2));
      expect(ap1.hashCode, equals(ap2.hashCode));
    });

    test('two APs with different bssid are not equal even with same ssid', () {
      const ap1 = WifiAP(bssid: 'aa:bb:cc:dd:ee:ff', ssid: 'Net', rssi: -50);
      const ap2 = WifiAP(bssid: 'aa:bb:cc:dd:ee:00', ssid: 'Net', rssi: -50);
      expect(ap1, isNot(equals(ap2)));
    });

    test('an AP with bssid and one without are not equal', () {
      const withBssid =
          WifiAP(bssid: 'aa:bb:cc:dd:ee:ff', ssid: 'Net', rssi: -50);
      const withoutBssid = WifiAP(ssid: 'Net', rssi: -50);
      expect(withBssid, isNot(equals(withoutBssid)));
    });

    test('two APs without bssid fall back to comparing the other fields', () {
      const ap1 = WifiAP(ssid: 'Net', rssi: -50);
      const ap2 = WifiAP(ssid: 'Net', rssi: -50);
      expect(ap1, equals(ap2));
      expect(ap1.hashCode, equals(ap2.hashCode));
    });

    test('two APs without bssid and different fields are not equal', () {
      const ap1 = WifiAP(ssid: 'Net', rssi: -50);
      const ap2 = WifiAP(ssid: 'Net', rssi: -60);
      expect(ap1, isNot(equals(ap2)));
    });
  });

  group('ConnectionStatus', () {
    test('stores state and optional IP address', () {
      final status = ConnectionStatus(
        state: WifiConnectionState.Connected,
        deviceIp: '192.168.1.100',
      );
      expect(status.state, equals(WifiConnectionState.Connected));
      expect(status.deviceIp, equals('192.168.1.100'));
      expect(status.failedReason, isNull);
    });

    test('stores failure reason', () {
      final status = ConnectionStatus(
        state: WifiConnectionState.ConnectionFailed,
        failedReason: WifiConnectFailedReason.AuthError,
      );
      expect(status.failedReason, equals(WifiConnectFailedReason.AuthError));
    });

    test('failedReason is null when not provided', () {
      final status = ConnectionStatus(state: WifiConnectionState.Connecting);
      expect(status.failedReason, isNull);
    });
  });
}
