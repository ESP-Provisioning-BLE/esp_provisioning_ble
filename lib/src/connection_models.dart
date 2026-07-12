// ignore_for_file: constant_identifier_names

/// Represents the state of a wifi connection.
enum WifiConnectionState {
  Connected,
  Connecting,
  Disconnected,
  ConnectionFailed,
}

/// Represents the reason for a wifi connection failure.
enum WifiConnectFailedReason {
  AuthError,
  NetworkNotFound,
}

/// The connection status of a device with a wifi network.
///
/// It provides:
///   - [WifiConnectionState] to indicate the current state of the connection.
///   - [deviceIp] to store the IP address of the connected device.
///   - [failedReason] to indicate the reason for the connection failure if applicable.
class ConnectionStatus {
  ConnectionStatus({
    required this.state,
    this.deviceIp,
    this.failedReason,
  });

  final WifiConnectionState state;
  final String? deviceIp;
  final WifiConnectFailedReason? failedReason;
}

/// Represents a wifi access point (AP).
class WifiAP {
  const WifiAP({
    required this.ssid,
    required this.rssi,
    this.active = false,
    this.private = true,
  });

  /// The SSID of the wifi access point.
  final String ssid;

  /// The received signal strength indicator (RSSI) of the wifi access point.
  final int rssi;

  /// Indicates if the wifi access point is active.
  final bool active;

  /// Indicates if the wifi access point is private.
  final bool private;

  /// Compares two wifi access points ([WifiAP]) based on their RSSI.
  int compareTo(WifiAP other) {
    if (rssi > other.rssi) {
      return -1;
    }
    if (rssi == other.rssi) {
      return 0;
    }
    return 1;
  }
}
