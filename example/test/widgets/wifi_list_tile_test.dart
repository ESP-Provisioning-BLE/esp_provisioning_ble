import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:example/src/widgets/wifi_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTile(WifiAP network) {
    return MaterialApp(
      home: Scaffold(
        body: WifiListTile(network: network, onTap: () {}),
      ),
    );
  }

  group('signal icon based on RSSI', () {
    testWidgets('shows full wifi icon for strong signal (>= -50)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTile(const WifiAP(ssid: 'Strong', rssi: -40)),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.wifi));
      expect(icon.icon, Icons.wifi);
    });

    testWidgets('shows 2-bar icon for medium signal (>= -70)', (tester) async {
      await tester.pumpWidget(
        buildTile(const WifiAP(ssid: 'Medium', rssi: -60)),
      );

      expect(find.byIcon(Icons.wifi_2_bar), findsOneWidget);
    });

    testWidgets('shows 1-bar icon for weak signal (< -70)', (tester) async {
      await tester.pumpWidget(buildTile(const WifiAP(ssid: 'Weak', rssi: -80)));

      expect(find.byIcon(Icons.wifi_1_bar), findsOneWidget);
    });
  });

  group('network info display', () {
    testWidgets('shows SSID and RSSI', (tester) async {
      await tester.pumpWidget(
        buildTile(const WifiAP(ssid: 'MyWifi', rssi: -55)),
      );

      expect(find.text('MyWifi'), findsOneWidget);
      expect(find.text('RSSI: -55 dBm'), findsOneWidget);
    });

    testWidgets('shows lock icon for private networks', (tester) async {
      await tester.pumpWidget(
        buildTile(const WifiAP(ssid: 'Private', rssi: -50, private: true)),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows open lock icon for public networks', (tester) async {
      await tester.pumpWidget(
        buildTile(const WifiAP(ssid: 'Open', rssi: -50, private: false)),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('appends BSSID to the subtitle when present', (tester) async {
      await tester.pumpWidget(buildTile(const WifiAP(
        ssid: 'MyWifi',
        rssi: -55,
        bssid: 'aa:bb:cc:dd:ee:ff',
      )));

      expect(
        find.text('RSSI: -55 dBm - BSSID: aa:bb:cc:dd:ee:ff'),
        findsOneWidget,
      );
    });

    testWidgets('omits BSSID from the subtitle when absent', (tester) async {
      await tester
          .pumpWidget(buildTile(const WifiAP(ssid: 'MyWifi', rssi: -55)));

      expect(find.text('RSSI: -55 dBm'), findsOneWidget);
    });
  });

  group('same-SSID warning', () {
    testWidgets('hidden by default', (tester) async {
      await tester
          .pumpWidget(buildTile(const WifiAP(ssid: 'MyWifi', rssi: -55)));

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('shown when sharesSsidWithOtherAp is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WifiListTile(
            network: const WifiAP(ssid: 'MyWifi', rssi: -55),
            onTap: () {},
            sharesSsidWithOtherAp: true,
          ),
        ),
      ));

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
