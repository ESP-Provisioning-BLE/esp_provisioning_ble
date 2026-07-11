import 'package:flutter/material.dart';

import '../services/provisioning_service.dart';
import '../widgets/wifi_list_tile.dart';
import '../widgets/wifi_password_dialog.dart';

/// Screen that handles WiFi scanning and provisioning through the ESP32.
///
/// Receives a connected [ProvisioningService] instance via route arguments.
/// The user scans for WiFi networks, selects one, enters the password,
/// and the device gets provisioned.
class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});

  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  ProvisioningService? _provService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provService ??=
        ModalRoute.of(context)!.settings.arguments as ProvisioningService;
    _provService!.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provService?.removeListener(_onUpdate);
    _provService?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provService = _provService!;
    final state = provService.state;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'WiFi Provisioning',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(provService, state),
    );
  }

  Widget _buildBody(ProvisioningService provService, ProvState state) {
    switch (state) {
      case ProvState.sessionReady:
        return _buildScanButton(provService);

      case ProvState.scanningWifi:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text('Scanning WiFi networks...'),
            ],
          ),
        );

      case ProvState.wifiReady:
        return _buildNetworkList(provService);

      case ProvState.configSending:
      case ProvState.polling:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text('Provisioning device...'),
            ],
          ),
        );

      case ProvState.success:
        return _buildSuccess(provService);

      case ProvState.failed:
      case ProvState.disconnected:
        return _buildError(provService);

      default:
        return const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        );
    }
  }

  Widget _buildScanButton(ProvisioningService provService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text('Session established'),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.wifi_find),
            label: const Text('Scan WiFi Networks'),
            onPressed: provService.scanWifi,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkList(ProvisioningService provService) {
    final networks = provService.wifiNetworks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${networks.length} networks found',
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Rescan'),
                onPressed: () {
                  provService.wifiNetworks = [];
                  provService.scanWifi();
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: networks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final network = networks[index];
              return WifiListTile(
                network: network,
                onTap: () => _onNetworkSelected(provService, network.ssid),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onNetworkSelected(
    ProvisioningService provService,
    String ssid,
  ) async {
    final credentials = await WifiPasswordDialog.show(context, ssid: ssid);
    if (credentials != null) {
      provService.sendConfig(
        credentials.ssid,
        credentials.password,
        customData: credentials.customData,
      );
    }
  }

  Widget _buildSuccess(ProvisioningService provService) {
    final ip = provService.connectionStatus?.deviceIp ?? '';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text('Provisioned!', style: TextStyle(fontSize: 24)),
          if (ip.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Device IP: $ip', style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ProvisioningService provService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            provService.errorMessage ?? 'Provisioning failed',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'If your ESP32 supports retries, wait a moment before restarting.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
