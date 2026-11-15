// This is a generated file - do not edit.
//
// Generated from wifi_constants.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'wifi_constants.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'wifi_constants.pbenum.dart';

class WifiConnectedState extends $pb.GeneratedMessage {
  factory WifiConnectedState({
    $core.String? ip4Addr,
    WifiAuthMode? authMode,
    $core.List<$core.int>? ssid,
    $core.List<$core.int>? bssid,
    $core.int? channel,
  }) {
    final result = create();
    if (ip4Addr != null) result.ip4Addr = ip4Addr;
    if (authMode != null) result.authMode = authMode;
    if (ssid != null) result.ssid = ssid;
    if (bssid != null) result.bssid = bssid;
    if (channel != null) result.channel = channel;
    return result;
  }

  WifiConnectedState._();

  factory WifiConnectedState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WifiConnectedState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WifiConnectedState',
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip4Addr')
    ..aE<WifiAuthMode>(2, _omitFieldNames ? '' : 'authMode',
        enumValues: WifiAuthMode.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'ssid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'bssid', $pb.PbFieldType.OY)
    ..aI(5, _omitFieldNames ? '' : 'channel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiConnectedState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiConnectedState copyWith(void Function(WifiConnectedState) updates) =>
      super.copyWith((message) => updates(message as WifiConnectedState))
          as WifiConnectedState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WifiConnectedState create() => WifiConnectedState._();
  @$core.override
  WifiConnectedState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WifiConnectedState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WifiConnectedState>(create);
  static WifiConnectedState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip4Addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip4Addr($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp4Addr() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp4Addr() => $_clearField(1);

  @$pb.TagNumber(2)
  WifiAuthMode get authMode => $_getN(1);
  @$pb.TagNumber(2)
  set authMode(WifiAuthMode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAuthMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get ssid => $_getN(2);
  @$pb.TagNumber(3)
  set ssid($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSsid() => $_has(2);
  @$pb.TagNumber(3)
  void clearSsid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get bssid => $_getN(3);
  @$pb.TagNumber(4)
  set bssid($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBssid() => $_has(3);
  @$pb.TagNumber(4)
  void clearBssid() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get channel => $_getIZ(4);
  @$pb.TagNumber(5)
  set channel($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChannel() => $_has(4);
  @$pb.TagNumber(5)
  void clearChannel() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
