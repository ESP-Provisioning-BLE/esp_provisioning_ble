import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/ble_scanner.dart';
import '../widgets/device_list_tile.dart';

/// How the scan filter text is interpreted by flutter_blue_plus.
enum ScanFilterMode {
  /// Substring match — uses [FlutterBluePlus.startScan] `withKeywords`.
  keywords,

  /// Exact name match — uses [FlutterBluePlus.startScan] `withNames`.
  names,
}

/// Screen that scans for BLE devices and displays them in a list.
/// The user can choose between substring (keywords) or exact (names) filtering.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _scanner = BleScanner();
  final _filterController = TextEditingController(text: 'PROV_');
  var _filterMode = ScanFilterMode.keywords;
  bool _autoScanStarted = false;

  @override
  void initState() {
    super.initState();
    _scanner.init();
    _scanner.addListener(_onScannerUpdate);
  }

  /// Triggers auto-scan exactly once when the adapter becomes ready.
  void _onScannerUpdate() {
    if (_scanner.isAdapterReady && !_autoScanStarted) {
      _autoScanStarted = true;
      _startScan();
    }
  }

  void _startScan() {
    final text = _filterController.text.trim();
    switch (_filterMode) {
      case ScanFilterMode.keywords:
        _scanner.startScan(withKeywords: text.isEmpty ? [] : [text]);
      case ScanFilterMode.names:
        _scanner.startScan(withNames: text.isEmpty ? [] : [text]);
    }
  }

  @override
  void dispose() {
    _scanner.removeListener(_onScannerUpdate);
    _scanner.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'BLE Devices',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListenableBuilder(
        listenable: _scanner,
        builder: (context, _) {
          if (!_scanner.isAdapterReady) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Bluetooth is turned off'),
                  SizedBox(height: 8),
                  Text(
                    'Enable Bluetooth in system settings to continue.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter mode selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SegmentedButton<ScanFilterMode>(
                  segments: const [
                    ButtonSegment(
                      value: ScanFilterMode.keywords,
                      label: Text('Keywords'),
                      icon: Icon(Icons.search),
                    ),
                    ButtonSegment(
                      value: ScanFilterMode.names,
                      label: Text('Names'),
                      icon: Icon(Icons.text_fields),
                    ),
                  ],
                  selected: {_filterMode},
                  onSelectionChanged: (selected) {
                    setState(() => _filterMode = selected.first);
                  },
                ),
              ),

              // Filter text input + scan button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _filterController,
                        decoration: InputDecoration(
                          labelText: _filterMode == ScanFilterMode.keywords
                              ? 'Device name keyword'
                              : 'Exact device name',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _scanner.isScanning
                          ? _scanner.stopScan
                          : _startScan,
                      child: Text(_scanner.isScanning ? 'Stop' : 'Scan'),
                    ),
                  ],
                ),
              ),

              // Scanning indicator
              if (_scanner.isScanning)
                const LinearProgressIndicator(color: Colors.purple),

              // Device list
              Expanded(
                child: _scanner.devices.isEmpty
                    ? Center(
                        child: Text(
                          _scanner.isScanning
                              ? 'Searching for devices...'
                              : 'No devices found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _scanner.devices.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = _scanner.devices[index];
                          return DeviceListTile(
                            result: result,
                            onTap: () => _onDeviceSelected(result),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDeviceSelected(ScanResult result) {
    _scanner.stopScan();
    Navigator.pushNamed(
      context,
      '/connect',
      arguments: result.device,
    );
  }
}
