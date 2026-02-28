part of 'ble_wifi_bloc.dart';

@immutable
abstract class BleWifiState {}

class BleWifiInitial extends BleWifiState {}

class BleWifiEstablishedConnectionState extends BleWifiState {}

class BleWifiEstablishedConnectionKeyMismatch extends BleWifiState {}

class BleWifiEstablishedConnectionFailedState extends BleWifiState {}

class BleWifiScanningNetworksState extends BleWifiState {}

class BleWifiScannedNetworksState extends BleWifiState {
  final List<Map<String, dynamic>> foundedNetworks;
  BleWifiScannedNetworksState({required this.foundedNetworks});
}

class BleWifiEmptyListNewtworksState extends BleWifiState {}

class BleWifiSentConfigState extends BleWifiState {}

class BleWifiGetStatusState extends BleWifiState {}

class BleWifiLoadingState extends BleWifiState {}

class BleWifiConnectedState extends BleWifiState {}

class BleWifiDisconnectedState extends BleWifiState {}

class BleWifiConnectionFailedState extends BleWifiState {
  final String failedReason;
  BleWifiConnectionFailedState({required this.failedReason});
}
