// ignore_for_file: constant_identifier_names

enum WifiConnectionState {
  Connected,
  Connecting,
  Disconnected,
  ConnectionFailed,
}

enum WifiConnectFailedReason {
  AuthError,
  NetworkNotFound,
}

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

class WifiAP {
  const WifiAP({
    required this.bssid,
    required this.ssid,
    required this.rssi,
    this.active = false,
    this.private = true,
  });

  final String bssid;
  final String ssid;
  final int rssi;
  final bool active;
  final bool private;

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
