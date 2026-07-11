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
    this.bssid,
    required this.ssid,
    required this.rssi,
    this.active = false,
    this.private = true,
  });

  /// MAC-style BSSID (`aa:bb:cc:dd:ee:ff`) of the access point, when known.
  ///
  /// Scan results always carry a BSSID (see [EspProv.scanResultResponse]),
  /// so this is only null for instances built by hand outside a scan.
  final String? bssid;
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

  /// Compares by [bssid] when both sides have one, since it uniquely
  /// identifies the physical AP a scan entry came from (unlike [ssid],
  /// which several APs can share). Falls back to comparing the other
  /// fields when either side has no [bssid].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WifiAP) return false;
    if (bssid == null && other.bssid == null) {
      return ssid == other.ssid &&
          rssi == other.rssi &&
          active == other.active &&
          private == other.private;
    }
    return bssid == other.bssid;
  }

  @override
  int get hashCode {
    if (bssid == null) {
      return Object.hash(ssid, rssi, active, private);
    }
    return bssid.hashCode;
  }
}
