import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/provisioning_service.dart';

/// Screen where the user selects the security mode, optionally enters the
/// proof-of-possession (PoP), and connects to the ESP32 device, establishing
/// a provisioning session.
///
/// On success, navigates to the WiFi configuration screen passing the
/// [ProvisioningService] instance (already connected with session established).
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _popController = TextEditingController(text: 'abcd1234');
  final _provService = ProvisioningService();
  bool _useSecurity1 = true;

  @override
  void initState() {
    super.initState();
    _provService.addListener(_onStateChange);
  }

  void _onStateChange() {
    // Navigate to WiFi screen once the session is established.
    if (_provService.state == ProvState.sessionReady) {
      Navigator.pushReplacementNamed(
        context,
        '/wifi',
        arguments: _provService,
      );
    }
    // Trigger rebuild for loading/error states.
    setState(() {});
  }

  @override
  void dispose() {
    _provService.removeListener(_onStateChange);
    _popController.dispose();
    // Do not dispose _provService here — it's passed to the WiFi screen.
    super.dispose();
  }

  void _connect() {
    final device = ModalRoute.of(context)!.settings.arguments as BluetoothDevice;
    final security = _useSecurity1
        ? Security1(pop: _popController.text)
        : Security0();
    _provService.connectAndEstablishSession(device, security);
  }

  @override
  Widget build(BuildContext context) {
    final state = _provService.state;
    final isLoading = state == ProvState.connecting ||
        state == ProvState.sessionEstablishing;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'Connect',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildBody(state, isLoading),
      ),
    );
  }

  Widget _buildBody(ProvState state, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text('Establishing secure session...'),
          ],
        ),
      );
    }

    if (state == ProvState.failed ||
        state == ProvState.disconnected ||
        state == ProvState.keyMismatch) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _provService.errorMessage ?? 'Connection failed',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                _provService.disconnect();
                _connect();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    // Idle state — show security mode selector and optional PoP input.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Security 0'),
              icon: Icon(Icons.lock_open),
            ),
            ButtonSegment(
              value: true,
              label: Text('Security 1'),
              icon: Icon(Icons.lock),
            ),
          ],
          selected: {_useSecurity1},
          onSelectionChanged: (selection) {
            setState(() {
              _useSecurity1 = selection.first;
            });
          },
        ),
        const SizedBox(height: 24),
        if (_useSecurity1) ...[
          const Text(
            'Enter the proof-of-possession PIN for this device:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _popController,
            decoration: const InputDecoration(
              labelText: 'Proof of Possession',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          const Text(
            'No encryption — connect directly without a proof of possession.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _connect,
            child: const Text('Connect'),
          ),
        ),
      ],
    );
  }
}
