import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// List tile displaying a discovered BLE device with its name and RSSI.
class DeviceListTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const DeviceListTile({super.key, required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bluetooth, color: Colors.purple),
      title: Text(result.device.platformName),
      subtitle: Text('RSSI: ${result.rssi} dBm'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
