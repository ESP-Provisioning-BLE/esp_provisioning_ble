import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:flutter/material.dart';

/// List tile displaying a WiFi network with its SSID, signal strength, and
/// lock icon for private networks.
class WifiListTile extends StatelessWidget {
  final WifiAP network;
  final VoidCallback onTap;

  /// Whether another scanned entry shares this network's SSID with a
  /// different BSSID (e.g. a dual-band router or a mesh node). Shows a
  /// warning icon next to the SSID when true, since the two entries are
  /// not necessarily the same physical access point.
  final bool sharesSsidWithOtherAp;

  const WifiListTile({
    super.key,
    required this.network,
    required this.onTap,
    this.sharesSsidWithOtherAp = false,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_signalIcon(network.rssi), color: Colors.purple),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(network.ssid)),
          if (sharesSsidWithOtherAp) ...[
            const SizedBox(width: 6),
            Tooltip(
              message:
                  'Another access point nearby is broadcasting the '
                  'same SSID with a different BSSID. This entry may not '
                  'be the same physical network as the other one(s).',
              child: Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        network.bssid != null
            ? 'RSSI: ${network.rssi} dBm - BSSID: ${network.bssid}'
            : 'RSSI: ${network.rssi} dBm',
      ),      trailing: network.private
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
