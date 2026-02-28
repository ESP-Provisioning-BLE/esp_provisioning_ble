import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages BLE device scanning using flutter_blue_plus.
///
/// Listens to the Bluetooth adapter state and provides methods to start/stop
/// scanning for ESP32 provisioning devices filtered by name prefix.
class BleScanner extends ChangeNotifier {
  final _logger = Logger();

  List<ScanResult> _devices = [];

  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<ScanResult>>? _scanResultsSub;

  List<ScanResult> get devices => _devices;

  /// Delegates to [FlutterBluePlus.isScanningNow] for real-time status.
  bool get isScanning => FlutterBluePlus.isScanningNow;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  BluetoothAdapterState get adapterState => _adapterState;

  /// Whether the Bluetooth adapter is powered on and ready to scan.
  bool get isAdapterReady => _adapterState == BluetoothAdapterState.on;

  /// Starts listening to the Bluetooth adapter state.
  /// Call this once when the scanner is first needed.
  void init() {
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      _logger.d('Adapter state: $state');
      notifyListeners();
    });
  }

  /// Requests the runtime permissions needed for BLE scanning.
  ///
  /// On Android, `ACCESS_FINE_LOCATION` is required on many devices for the
  /// BLE scanner to return results, even with `minSdk 31`.
  Future<void> _requestPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    _logger.d('Permissions - scan: $scanStatus, connect: $connectStatus');

    if (Platform.isAndroid) {
      final locStatus = await Permission.locationWhenInUse.request();
      _logger.d('Permissions - location: $locStatus');
    }
  }

  /// Starts scanning for BLE devices whose advertised name matches [prefix].
  ///
  /// Uses [FlutterBluePlus.startScan] with [withKeywords] to filter results
  /// at the platform level. Results are deduplicated in Dart by remote ID.
  Future<void> startScan({
    String prefix = 'PROV_',
    int timeout = 15,
  }) async {
    _devices = [];
    notifyListeners();

    await _requestPermissions();

    // Stop any previous scan before starting a new one.
    if (FlutterBluePlus.isScanningNow) {
      _logger.d('Stopping previous scan before starting new one');
      await FlutterBluePlus.stopScan();
    }

    // Subscribe to results before starting scan (recommended FBP pattern).
    _scanResultsSub?.cancel();
    _scanResultsSub = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isEmpty) return;
        for (final r in results) {
          _logger.d(
            'Discovered: "${r.device.platformName}" '
            '${r.device.remoteId} RSSI: ${r.rssi}',
          );
          final alreadyFound = _devices.any(
            (d) => d.device.remoteId == r.device.remoteId,
          );
          if (!alreadyFound) {
            _devices = [..._devices, r];
            notifyListeners();
          }
        }
      },
      onError: (e) => _logger.e('scanResults error: $e'),
    );

    // Auto-cancel subscription when scan completes.
    FlutterBluePlus.cancelWhenScanComplete(_scanResultsSub!);

    _logger.i('Starting BLE scan with prefix "$prefix" for ${timeout}s...');

    // withKeywords filters by advertised name at the FBP level.
    // continuousUpdates keeps the scan delivering results continuously.
    await FlutterBluePlus.startScan(
      withKeywords: [prefix],
      timeout: Duration(seconds: timeout),
      continuousUpdates: true,
    );

    _logger.i('Scan started. Waiting for results...');
    notifyListeners();
  }

  /// Stops an ongoing BLE scan.
  Future<void> stopScan() async {
    _logger.d('stopScan called');
    await FlutterBluePlus.stopScan();
    notifyListeners();
  }

  @override
  void dispose() {
    _adapterSub?.cancel();
    _scanResultsSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
