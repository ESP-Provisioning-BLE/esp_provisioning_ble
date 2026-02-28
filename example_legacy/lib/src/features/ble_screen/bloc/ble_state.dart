part of 'ble_bloc.dart';

@immutable
abstract class BleState {}

class BleInitialState extends BleState {}

class BleEnableState extends BleState {}

class BleDisabledState extends BleState {}

class BlePermissionEnableState extends BleState {}

class BlePermissionDeniedState extends BleState {}

class BlePermissionDeniedForever extends BleState {}

class LocationEnable extends BleState {}

class LocationDisabled extends BleState {}

class PermissionLocationDenied extends BleState {}

class PermissionLocationDeniedForever extends BleState {}

class PermissionLocationUnableToDetermine extends BleState {}

class BleReadytoScan extends BleState {}

class BleScanning extends BleState {}

class BleStopScan extends BleState {}

class BleScanningError extends BleState {}

class BleScanCompleted extends BleState {
  final List<Map<String, dynamic>> foundedDevices;
  final bool? stopped;
  BleScanCompleted({required this.foundedDevices, this.stopped});
}

class BleEmptyList extends BleState {}

class BleLoadingState extends BleState {}

class BleConnected extends BleState {}

class BleConnectedFailed extends BleState {}
