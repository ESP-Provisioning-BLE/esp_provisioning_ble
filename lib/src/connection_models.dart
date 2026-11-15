// ignore_for_file: constant_identifier_names

/// State of the device's Wi-Fi connection, as reported by
/// [EspProv.getStatus].
enum WifiConnectionState {
  /// The device joined the network and got an IP address, which is in
  /// [ConnectionStatus.deviceIp].
  Connected,

  /// The device is still trying to connect.
  Connecting,

  /// The device is not connected. The protocol defines this state, but
  /// ESP-IDF's provisioning manager (as of v5.4) reports a connection that
  /// failed or dropped as [ConnectionFailed] instead.
  Disconnected,

  /// The device could not connect; see [ConnectionStatus.failedReason].
  ///
  /// It is not necessarily final: a firmware that keeps retrying can still
  /// connect later. This package does not retry by itself.
  ConnectionFailed,
}

/// Why the device could not connect to the Wi-Fi network, when the state is
/// [WifiConnectionState.ConnectionFailed].
enum WifiConnectFailedReason {
  /// Authentication with the access point failed, typically because the
  /// password is wrong. [EspProv.getStatus] also uses it when the device
  /// does not report [NetworkNotFound].
  AuthError,

  /// The device did not find the network, for example because the SSID is
  /// wrong or the access point is out of range.
  NetworkNotFound,
}

/// The state of the device's Wi-Fi connection, returned by
/// [EspProv.getStatus].
class ConnectionStatus {
  /// Creates a connection status with the given [state] and, when they
  /// apply, the [deviceIp] and the [failedReason].
  ConnectionStatus({required this.state, this.deviceIp, this.failedReason});

  /// The state of the connection.
  final WifiConnectionState state;

  /// The device's IPv4 address in dotted form, such as `192.168.1.20`.
  ///
  /// [EspProv.getStatus] sets it only when [state] is
  /// [WifiConnectionState.Connected].
  final String? deviceIp;

  /// Why the connection failed.
  ///
  /// [EspProv.getStatus] sets it only when [state] is
  /// [WifiConnectionState.ConnectionFailed].
  final WifiConnectFailedReason? failedReason;
}

/// A Wi-Fi access point found by the device during a scan.
///
/// [EspProv.scan] and [EspProv.startScanWiFi] return a list of them.
class WifiAP {
  /// Creates an access point. Only [ssid] and [rssi] are required.
  const WifiAP({
    this.bssid,
    required this.ssid,
    required this.rssi,
    this.active = false,
    this.private = true,
  });

  /// MAC-style BSSID (`aa:bb:cc:dd:ee:ff`) of the access point, when known.
  ///
  /// In scan results it is `null` only if the device did not send a 6-byte
  /// BSSID (see [EspProv.scanResultResponse]). ESP-IDF's provisioning
  /// manager always sends one.
  final String? bssid;

  /// The network name (SSID), decoded as UTF-8.
  final String ssid;

  /// The received signal strength, in dBm, as measured by the device.
  /// Values closer to zero mean a stronger signal.
  final int rssi;

  /// A flag for the app's own use, `false` by default.
  ///
  /// The device does not report it and this package never sets it, so scan
  /// results always have `false`.
  final bool active;

  /// Whether joining the network needs credentials.
  ///
  /// In scan results it is `false` only for Open and OWE (Wi-Fi Enhanced
  /// Open) networks, and `true` for every other auth mode, including WPA3
  /// and modes this package does not know. It defaults to `true`.
  final bool private;

  /// Orders access points by signal strength, strongest first.
  ///
  /// Returns a negative number if this access point has a higher [rssi]
  /// than [other], zero if both are equal and a positive number otherwise,
  /// so `aps.sort((a, b) => a.compareTo(b))` puts the strongest first.
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

  /// A hash code consistent with [operator ==]: it uses [bssid] when there
  /// is one, and the other fields otherwise.
  @override
  int get hashCode {
    if (bssid == null) {
      return Object.hash(ssid, rssi, active, private);
    }
    return bssid.hashCode;
  }
}
