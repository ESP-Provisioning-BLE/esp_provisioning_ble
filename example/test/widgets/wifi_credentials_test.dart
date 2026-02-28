import 'package:example/src/widgets/wifi_password_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WifiCredentials', () {
    test('stores ssid, password, and customData', () {
      const creds = WifiCredentials(
        ssid: 'MyNetwork',
        password: 'secret123',
        customData: 'Hello from app',
      );

      expect(creds.ssid, 'MyNetwork');
      expect(creds.password, 'secret123');
      expect(creds.customData, 'Hello from app');
    });

    test('supports empty custom data', () {
      const creds = WifiCredentials(
        ssid: 'Net',
        password: 'pass',
        customData: '',
      );

      expect(creds.customData, isEmpty);
    });
  });
}
