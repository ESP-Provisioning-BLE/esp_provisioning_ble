import 'dart:async';
import 'dart:convert';

import 'package:esp_provisioning_ble/esp_provisioning_ble.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import 'transport_ble.dart';

/// Provisioning workflow states, representing the linear flow from
/// connection through WiFi configuration.
enum ProvState {
  idle,
  connecting,
  sessionEstablishing,
  sessionReady,
  scanningWifi,
  wifiReady,
  configSending,
  polling,
  success,
  failed,
  disconnected,
  keyMismatch,
}

/// Manages the ESP32 provisioning workflow over BLE.
///
/// Wraps [EspProv] and [TransportBLE] to provide a simple interface for
/// the UI layer. Exposes state changes via [ChangeNotifier] so screens
/// can react using [ListenableBuilder].
class ProvisioningService extends ChangeNotifier {
  final _logger = Logger();

  EspProv? _prov;
  TransportBLE? _transport;
  Timer? _statusTimer;

  ProvState _state = ProvState.idle;
  String? errorMessage;
  List<WifiAP> wifiNetworks = [];
  ConnectionStatus? connectionStatus;

  ProvState get state => _state;

  void _setState(ProvState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Connects to the BLE device and establishes a secure provisioning session.
  ///
  /// Creates a [TransportBLE] adapter and [EspProv] instance with [Security1]
  /// using the given proof-of-possession [pop]. The session establishment
  /// performs a Curve25519 key exchange with the ESP32.
  Future<void> connectAndEstablishSession(
    BluetoothDevice device,
    String pop,
  ) async {
    _setState(ProvState.connecting);

    _transport = TransportBLE(device);
    final connected = await _transport!.connect();

    if (!connected) {
      errorMessage = 'Failed to connect to device';
      _setState(ProvState.failed);
      return;
    }

    _prov = EspProv(
      transport: _transport!,
      security: Security1(pop: pop),
    );

    _setState(ProvState.sessionEstablishing);

    final sessionStatus = await _prov!.establishSession();
    _logger.d('Session status: $sessionStatus');

    switch (sessionStatus) {
      case EstablishSessionStatus.connected:
        _setState(ProvState.sessionReady);
      case EstablishSessionStatus.disconnected:
        errorMessage = 'Device disconnected during session establishment';
        _setState(ProvState.disconnected);
      case EstablishSessionStatus.keymismatch:
        errorMessage = 'Wrong proof-of-possession (key mismatch)';
        _setState(ProvState.keyMismatch);
    }
  }

  /// Scans for available WiFi networks through the connected ESP32.
  ///
  /// The ESP32 performs the actual WiFi scan and returns results over BLE.
  /// Results are stored in [wifiNetworks].
  Future<void> scanWifi() async {
    _setState(ProvState.scanningWifi);

    try {
      final networks = await _prov!.startScanWiFi();
      wifiNetworks = networks;
      _logger.d('Found ${networks.length} WiFi networks');
      _setState(ProvState.wifiReady);
    } catch (e) {
      _logger.e('WiFi scan error: $e');
      errorMessage = 'Failed to scan WiFi networks';
      _setState(ProvState.failed);
    }
  }

  /// Sends WiFi credentials to the ESP32 and starts polling for connection status.
  ///
  /// Optionally sends [customData] before configuring WiFi (useful for
  /// application-specific setup like device registration tokens).
  Future<void> sendConfig(
    String ssid,
    String password, {
    String? customData,
  }) async {
    _setState(ProvState.configSending);

    try {
      if (customData != null && customData.isNotEmpty) {
        final customBytes = Uint8List.fromList(utf8.encode(customData));
        final response = await _prov!.sendReceiveCustomData(customBytes);
        _logger.i('Custom data response: ${utf8.decode(response)}');
      }

      await _prov!.sendWifiConfig(ssid: ssid, password: password);
      await _prov!.applyWifiConfig();
      _pollStatus();
    } catch (e) {
      _logger.e('Config error: $e');
      errorMessage = 'Failed to send WiFi configuration';
      _setState(ProvState.failed);
    }
  }

  /// Polls the ESP32 for WiFi connection status every 400ms.
  ///
  /// Stops polling once a terminal state is reached (connected, disconnected,
  /// or connection failed).
  void _pollStatus() {
    _setState(ProvState.polling);
    _statusTimer?.cancel();

    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (timer) async {
        try {
          final status = await _prov!.getStatus();
          connectionStatus = status;

          switch (status.state) {
            case WifiConnectionState.Connected:
              timer.cancel();
              _logger.d('Device IP: ${status.deviceIp}');
              _setState(ProvState.success);
            case WifiConnectionState.Connecting:
              // Keep polling
              break;
            case WifiConnectionState.Disconnected:
              timer.cancel();
              errorMessage = 'Device disconnected';
              _setState(ProvState.disconnected);
            case WifiConnectionState.ConnectionFailed:
              timer.cancel();
              errorMessage = _failedReasonMessage(status.failedReason);
              _setState(ProvState.failed);
          }
        } catch (e) {
          timer.cancel();
          _logger.e('Status poll error: $e');
          errorMessage = 'Lost connection while checking status';
          _setState(ProvState.failed);
        }
      },
    );
  }

  String _failedReasonMessage(WifiConnectFailedReason? reason) {
    switch (reason) {
      case WifiConnectFailedReason.AuthError:
        return 'Authentication error (wrong WiFi password)';
      case WifiConnectFailedReason.NetworkNotFound:
        return 'Network not found';
      default:
        return 'Connection failed';
    }
  }

  /// Disconnects from the BLE device and cleans up resources.
  Future<void> disconnect() async {
    _statusTimer?.cancel();
    await _prov?.dispose();
    _prov = null;
    _transport = null;
    wifiNetworks = [];
    connectionStatus = null;
    errorMessage = null;
    _setState(ProvState.idle);
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _prov?.dispose();
    super.dispose();
  }
}
