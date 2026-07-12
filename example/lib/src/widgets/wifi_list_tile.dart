import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:flutter/material.dart';

/// List tile displaying a WiFi network with its SSID, signal strength, and
/// lock icon for private networks.
class WifiListTile extends StatelessWidget {
  final WifiAP network;
  final VoidCallback onTap;

  const WifiListTile({super.key, required this.network, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_signalIcon(network.rssi), color: Colors.purple),
      title: Text(network.ssid),
      subtitle: Text('RSSI: ${network.rssi} dBm'),
      trailing: network.private
          ? const Icon(Icons.lock, size: 16)
          : const Icon(Icons.lock_open, size: 16),
      onTap: onTap,
    );
  }

  IconData _signalIcon(int rssi) {
    if (rssi >= -50) return Icons.wifi;
    if (rssi >= -70) return Icons.wifi_2_bar;
    return Icons.wifi_1_bar;
  }
}
