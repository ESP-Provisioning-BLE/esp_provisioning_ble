import 'package:flutter/material.dart';

import 'src/screens/connect_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/scan_screen.dart';
import 'src/screens/wifi_screen.dart';

void main() {
  runApp(const ProvisioningApp());
}

class ProvisioningApp extends StatelessWidget {
  const ProvisioningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Provisioning',
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/scan': (_) => const ScanScreen(),
        '/connect': (_) => const ConnectScreen(),
        '/wifi': (_) => const WifiScreen(),
      },
    );
  }
}
