// This is a generated file - do not edit.
//
// Generated from wifi_config.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $1;
import 'wifi_config.pbenum.dart';
import 'wifi_constants.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'wifi_config.pbenum.dart';

class CmdGetStatus extends $pb.GeneratedMessage {
  factory CmdGetStatus() => create();

  CmdGetStatus._();

  factory CmdGetStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdGetStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdGetStatus',
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdGetStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdGetStatus copyWith(void Function(CmdGetStatus) updates) =>
      super.copyWith((message) => updates(message as CmdGetStatus))
          as CmdGetStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdGetStatus create() => CmdGetStatus._();
  @$core.override
  CmdGetStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdGetStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdGetStatus>(create);
  static CmdGetStatus? _defaultInstance;
}

enum RespGetStatus_State { failReason, connected, notSet }

class RespGetStatus extends $pb.GeneratedMessage {
  factory RespGetStatus({
    $1.Status? status,
    $0.WifiStationState? staState,
    $0.WifiConnectFailedReason? failReason,
    $0.WifiConnectedState? connected,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (staState != null) result.staState = staState;
    if (failReason != null) result.failReason = failReason;
    if (connected != null) result.connected = connected;
    return result;
  }

  RespGetStatus._();

  factory RespGetStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespGetStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RespGetStatus_State>
      _RespGetStatus_StateByTag = {
    10: RespGetStatus_State.failReason,
    11: RespGetStatus_State.connected,
    0: RespGetStatus_State.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespGetStatus',
      createEmptyInstance: create)
    ..oo(0, [10, 11])
    ..aE<$1.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $1.Status.values)
    ..aE<$0.WifiStationState>(2, _omitFieldNames ? '' : 'staState',
        enumValues: $0.WifiStationState.values)
    ..aE<$0.WifiConnectFailedReason>(10, _omitFieldNames ? '' : 'failReason',
        enumValues: $0.WifiConnectFailedReason.values)
    ..aOM<$0.WifiConnectedState>(11, _omitFieldNames ? '' : 'connected',
        subBuilder: $0.WifiConnectedState.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespGetStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespGetStatus copyWith(void Function(RespGetStatus) updates) =>
      super.copyWith((message) => updates(message as RespGetStatus))
          as RespGetStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespGetStatus create() => RespGetStatus._();
  @$core.override
  RespGetStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespGetStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespGetStatus>(create);
  static RespGetStatus? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  RespGetStatus_State whichState() =>
      _RespGetStatus_StateByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearState() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $1.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($1.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.WifiStationState get staState => $_getN(1);
  @$pb.TagNumber(2)
  set staState($0.WifiStationState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStaState() => $_has(1);
  @$pb.TagNumber(2)
  void clearStaState() => $_clearField(2);

  @$pb.TagNumber(10)
  $0.WifiConnectFailedReason get failReason => $_getN(2);
  @$pb.TagNumber(10)
  set failReason($0.WifiConnectFailedReason value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasFailReason() => $_has(2);
  @$pb.TagNumber(10)
  void clearFailReason() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.WifiConnectedState get connected => $_getN(3);
  @$pb.TagNumber(11)
  set connected($0.WifiConnectedState value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasConnected() => $_has(3);
  @$pb.TagNumber(11)
  void clearConnected() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.WifiConnectedState ensureConnected() => $_ensure(3);
}

class CmdSetConfig extends $pb.GeneratedMessage {
  factory CmdSetConfig({
    $core.List<$core.int>? ssid,
    $core.List<$core.int>? passphrase,
    $core.List<$core.int>? bssid,
    $core.int? channel,
  }) {
    final result = create();
    if (ssid != null) result.ssid = ssid;
    if (passphrase != null) result.passphrase = passphrase;
    if (bssid != null) result.bssid = bssid;
    if (channel != null) result.channel = channel;
    return result;
  }

  CmdSetConfig._();

  factory CmdSetConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdSetConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdSetConfig',
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'ssid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'passphrase', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'bssid', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'channel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdSetConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdSetConfig copyWith(void Function(CmdSetConfig) updates) =>
      super.copyWith((message) => updates(message as CmdSetConfig))
          as CmdSetConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdSetConfig create() => CmdSetConfig._();
  @$core.override
  CmdSetConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdSetConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdSetConfig>(create);
  static CmdSetConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get ssid => $_getN(0);
  @$pb.TagNumber(1)
  set ssid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSsid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSsid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get passphrase => $_getN(1);
  @$pb.TagNumber(2)
  set passphrase($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassphrase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get bssid => $_getN(2);
  @$pb.TagNumber(3)
  set bssid($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBssid() => $_has(2);
  @$pb.TagNumber(3)
  void clearBssid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get channel => $_getIZ(3);
  @$pb.TagNumber(4)
  set channel($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(4)
  void clearChannel() => $_clearField(4);
}

class RespSetConfig extends $pb.GeneratedMessage {
  factory RespSetConfig({
    $1.Status? status,
  }) {
    final result = create();
    if (status != null) result.status = status;
    return result;
  }

  RespSetConfig._();

  factory RespSetConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespSetConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespSetConfig',
      createEmptyInstance: create)
    ..aE<$1.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $1.Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespSetConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespSetConfig copyWith(void Function(RespSetConfig) updates) =>
      super.copyWith((message) => updates(message as RespSetConfig))
          as RespSetConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespSetConfig create() => RespSetConfig._();
  @$core.override
  RespSetConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespSetConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespSetConfig>(create);
  static RespSetConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($1.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
}

class CmdApplyConfig extends $pb.GeneratedMessage {
  factory CmdApplyConfig() => create();

  CmdApplyConfig._();

  factory CmdApplyConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdApplyConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdApplyConfig',
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdApplyConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdApplyConfig copyWith(void Function(CmdApplyConfig) updates) =>
      super.copyWith((message) => updates(message as CmdApplyConfig))
          as CmdApplyConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdApplyConfig create() => CmdApplyConfig._();
  @$core.override
  CmdApplyConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdApplyConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdApplyConfig>(create);
  static CmdApplyConfig? _defaultInstance;
}

class RespApplyConfig extends $pb.GeneratedMessage {
  factory RespApplyConfig({
    $1.Status? status,
  }) {
    final result = create();
    if (status != null) result.status = status;
    return result;
  }

  RespApplyConfig._();

  factory RespApplyConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespApplyConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespApplyConfig',
      createEmptyInstance: create)
    ..aE<$1.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $1.Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespApplyConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespApplyConfig copyWith(void Function(RespApplyConfig) updates) =>
      super.copyWith((message) => updates(message as RespApplyConfig))
          as RespApplyConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespApplyConfig create() => RespApplyConfig._();
  @$core.override
  RespApplyConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespApplyConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespApplyConfig>(create);
  static RespApplyConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($1.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
}

enum WiFiConfigPayload_Payload {
  cmdGetStatus,
  respGetStatus,
  cmdSetConfig,
  respSetConfig,
  cmdApplyConfig,
  respApplyConfig,
  notSet
}

class WiFiConfigPayload extends $pb.GeneratedMessage {
  factory WiFiConfigPayload({
    WiFiConfigMsgType? msg,
    CmdGetStatus? cmdGetStatus,
    RespGetStatus? respGetStatus,
    CmdSetConfig? cmdSetConfig,
    RespSetConfig? respSetConfig,
    CmdApplyConfig? cmdApplyConfig,
    RespApplyConfig? respApplyConfig,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    if (cmdGetStatus != null) result.cmdGetStatus = cmdGetStatus;
    if (respGetStatus != null) result.respGetStatus = respGetStatus;
    if (cmdSetConfig != null) result.cmdSetConfig = cmdSetConfig;
    if (respSetConfig != null) result.respSetConfig = respSetConfig;
    if (cmdApplyConfig != null) result.cmdApplyConfig = cmdApplyConfig;
    if (respApplyConfig != null) result.respApplyConfig = respApplyConfig;
    return result;
  }

  WiFiConfigPayload._();

  factory WiFiConfigPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WiFiConfigPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WiFiConfigPayload_Payload>
      _WiFiConfigPayload_PayloadByTag = {
    10: WiFiConfigPayload_Payload.cmdGetStatus,
    11: WiFiConfigPayload_Payload.respGetStatus,
    12: WiFiConfigPayload_Payload.cmdSetConfig,
    13: WiFiConfigPayload_Payload.respSetConfig,
    14: WiFiConfigPayload_Payload.cmdApplyConfig,
    15: WiFiConfigPayload_Payload.respApplyConfig,
    0: WiFiConfigPayload_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WiFiConfigPayload',
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12, 13, 14, 15])
    ..aE<WiFiConfigMsgType>(1, _omitFieldNames ? '' : 'msg',
        enumValues: WiFiConfigMsgType.values)
    ..aOM<CmdGetStatus>(10, _omitFieldNames ? '' : 'cmdGetStatus',
        subBuilder: CmdGetStatus.create)
    ..aOM<RespGetStatus>(11, _omitFieldNames ? '' : 'respGetStatus',
        subBuilder: RespGetStatus.create)
    ..aOM<CmdSetConfig>(12, _omitFieldNames ? '' : 'cmdSetConfig',
        subBuilder: CmdSetConfig.create)
    ..aOM<RespSetConfig>(13, _omitFieldNames ? '' : 'respSetConfig',
        subBuilder: RespSetConfig.create)
    ..aOM<CmdApplyConfig>(14, _omitFieldNames ? '' : 'cmdApplyConfig',
        subBuilder: CmdApplyConfig.create)
    ..aOM<RespApplyConfig>(15, _omitFieldNames ? '' : 'respApplyConfig',
        subBuilder: RespApplyConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiConfigPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiConfigPayload copyWith(void Function(WiFiConfigPayload) updates) =>
      super.copyWith((message) => updates(message as WiFiConfigPayload))
          as WiFiConfigPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WiFiConfigPayload create() => WiFiConfigPayload._();
  @$core.override
  WiFiConfigPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WiFiConfigPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WiFiConfigPayload>(create);
  static WiFiConfigPayload? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  WiFiConfigPayload_Payload whichPayload() =>
      _WiFiConfigPayload_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  WiFiConfigMsgType get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg(WiFiConfigMsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(10)
  CmdGetStatus get cmdGetStatus => $_getN(1);
  @$pb.TagNumber(10)
  set cmdGetStatus(CmdGetStatus value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCmdGetStatus() => $_has(1);
  @$pb.TagNumber(10)
  void clearCmdGetStatus() => $_clearField(10);
  @$pb.TagNumber(10)
  CmdGetStatus ensureCmdGetStatus() => $_ensure(1);

  @$pb.TagNumber(11)
  RespGetStatus get respGetStatus => $_getN(2);
  @$pb.TagNumber(11)
  set respGetStatus(RespGetStatus value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasRespGetStatus() => $_has(2);
  @$pb.TagNumber(11)
  void clearRespGetStatus() => $_clearField(11);
  @$pb.TagNumber(11)
  RespGetStatus ensureRespGetStatus() => $_ensure(2);

  @$pb.TagNumber(12)
  CmdSetConfig get cmdSetConfig => $_getN(3);
  @$pb.TagNumber(12)
  set cmdSetConfig(CmdSetConfig value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCmdSetConfig() => $_has(3);
  @$pb.TagNumber(12)
  void clearCmdSetConfig() => $_clearField(12);
  @$pb.TagNumber(12)
  CmdSetConfig ensureCmdSetConfig() => $_ensure(3);

  @$pb.TagNumber(13)
  RespSetConfig get respSetConfig => $_getN(4);
  @$pb.TagNumber(13)
  set respSetConfig(RespSetConfig value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasRespSetConfig() => $_has(4);
  @$pb.TagNumber(13)
  void clearRespSetConfig() => $_clearField(13);
  @$pb.TagNumber(13)
  RespSetConfig ensureRespSetConfig() => $_ensure(4);

  @$pb.TagNumber(14)
  CmdApplyConfig get cmdApplyConfig => $_getN(5);
  @$pb.TagNumber(14)
  set cmdApplyConfig(CmdApplyConfig value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCmdApplyConfig() => $_has(5);
  @$pb.TagNumber(14)
  void clearCmdApplyConfig() => $_clearField(14);
  @$pb.TagNumber(14)
  CmdApplyConfig ensureCmdApplyConfig() => $_ensure(5);

  @$pb.TagNumber(15)
  RespApplyConfig get respApplyConfig => $_getN(6);
  @$pb.TagNumber(15)
  set respApplyConfig(RespApplyConfig value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasRespApplyConfig() => $_has(6);
  @$pb.TagNumber(15)
  void clearRespApplyConfig() => $_clearField(15);
  @$pb.TagNumber(15)
  RespApplyConfig ensureRespApplyConfig() => $_ensure(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
