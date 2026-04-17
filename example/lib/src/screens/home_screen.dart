import 'package:flutter/material.dart';

/// Entry screen with a button to start the BLE provisioning flow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'ESP32 Provisioning',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.bluetooth_searching),
          label: const Text('Start Provisioning'),
          onPressed: () => Navigator.pushNamed(context, '/scan'),
        ),
      ),
    );
  }
}
