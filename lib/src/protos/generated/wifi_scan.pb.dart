// This is a generated file - do not edit.
//
// Generated from wifi_scan.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $1;
import 'wifi_constants.pbenum.dart' as $0;
import 'wifi_scan.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'wifi_scan.pbenum.dart';

class CmdScanStart extends $pb.GeneratedMessage {
  factory CmdScanStart({
    $core.bool? blocking,
    $core.bool? passive,
    $core.int? groupChannels,
    $core.int? periodMs,
  }) {
    final result = create();
    if (blocking != null) result.blocking = blocking;
    if (passive != null) result.passive = passive;
    if (groupChannels != null) result.groupChannels = groupChannels;
    if (periodMs != null) result.periodMs = periodMs;
    return result;
  }

  CmdScanStart._();

  factory CmdScanStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdScanStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdScanStart',
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'blocking')
    ..aOB(2, _omitFieldNames ? '' : 'passive')
    ..aI(3, _omitFieldNames ? '' : 'groupChannels',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'periodMs', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanStart copyWith(void Function(CmdScanStart) updates) =>
      super.copyWith((message) => updates(message as CmdScanStart))
          as CmdScanStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdScanStart create() => CmdScanStart._();
  @$core.override
  CmdScanStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdScanStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdScanStart>(create);
  static CmdScanStart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get blocking => $_getBF(0);
  @$pb.TagNumber(1)
  set blocking($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlocking() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlocking() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get passive => $_getBF(1);
  @$pb.TagNumber(2)
  set passive($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassive() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassive() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get groupChannels => $_getIZ(2);
  @$pb.TagNumber(3)
  set groupChannels($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupChannels() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupChannels() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get periodMs => $_getIZ(3);
  @$pb.TagNumber(4)
  set periodMs($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPeriodMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeriodMs() => $_clearField(4);
}

class RespScanStart extends $pb.GeneratedMessage {
  factory RespScanStart() => create();

  RespScanStart._();

  factory RespScanStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespScanStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespScanStart',
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanStart copyWith(void Function(RespScanStart) updates) =>
      super.copyWith((message) => updates(message as RespScanStart))
          as RespScanStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespScanStart create() => RespScanStart._();
  @$core.override
  RespScanStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespScanStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespScanStart>(create);
  static RespScanStart? _defaultInstance;
}

class CmdScanStatus extends $pb.GeneratedMessage {
  factory CmdScanStatus() => create();

  CmdScanStatus._();

  factory CmdScanStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdScanStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdScanStatus',
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanStatus copyWith(void Function(CmdScanStatus) updates) =>
      super.copyWith((message) => updates(message as CmdScanStatus))
          as CmdScanStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdScanStatus create() => CmdScanStatus._();
  @$core.override
  CmdScanStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdScanStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdScanStatus>(create);
  static CmdScanStatus? _defaultInstance;
}

class RespScanStatus extends $pb.GeneratedMessage {
  factory RespScanStatus({
    $core.bool? scanFinished,
    $core.int? resultCount,
  }) {
    final result = create();
    if (scanFinished != null) result.scanFinished = scanFinished;
    if (resultCount != null) result.resultCount = resultCount;
    return result;
  }

  RespScanStatus._();

  factory RespScanStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespScanStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespScanStatus',
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'scanFinished')
    ..aI(2, _omitFieldNames ? '' : 'resultCount',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanStatus copyWith(void Function(RespScanStatus) updates) =>
      super.copyWith((message) => updates(message as RespScanStatus))
          as RespScanStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespScanStatus create() => RespScanStatus._();
  @$core.override
  RespScanStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespScanStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespScanStatus>(create);
  static RespScanStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get scanFinished => $_getBF(0);
  @$pb.TagNumber(1)
  set scanFinished($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScanFinished() => $_has(0);
  @$pb.TagNumber(1)
  void clearScanFinished() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get resultCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set resultCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasResultCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearResultCount() => $_clearField(2);
}

class CmdScanResult extends $pb.GeneratedMessage {
  factory CmdScanResult({
    $core.int? startIndex,
    $core.int? count,
  }) {
    final result = create();
    if (startIndex != null) result.startIndex = startIndex;
    if (count != null) result.count = count;
    return result;
  }

  CmdScanResult._();

  factory CmdScanResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CmdScanResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CmdScanResult',
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'startIndex', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CmdScanResult copyWith(void Function(CmdScanResult) updates) =>
      super.copyWith((message) => updates(message as CmdScanResult))
          as CmdScanResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CmdScanResult create() => CmdScanResult._();
  @$core.override
  CmdScanResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CmdScanResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CmdScanResult>(create);
  static CmdScanResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set startIndex($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

class WiFiScanResult extends $pb.GeneratedMessage {
  factory WiFiScanResult({
    $core.List<$core.int>? ssid,
    $core.int? channel,
    $core.int? rssi,
    $core.List<$core.int>? bssid,
    $0.WifiAuthMode? auth,
  }) {
    final result = create();
    if (ssid != null) result.ssid = ssid;
    if (channel != null) result.channel = channel;
    if (rssi != null) result.rssi = rssi;
    if (bssid != null) result.bssid = bssid;
    if (auth != null) result.auth = auth;
    return result;
  }

  WiFiScanResult._();

  factory WiFiScanResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WiFiScanResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WiFiScanResult',
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'ssid', $pb.PbFieldType.OY)
    ..aI(2, _omitFieldNames ? '' : 'channel', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'rssi')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'bssid', $pb.PbFieldType.OY)
    ..aE<$0.WifiAuthMode>(5, _omitFieldNames ? '' : 'auth',
        enumValues: $0.WifiAuthMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiScanResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiScanResult copyWith(void Function(WiFiScanResult) updates) =>
      super.copyWith((message) => updates(message as WiFiScanResult))
          as WiFiScanResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WiFiScanResult create() => WiFiScanResult._();
  @$core.override
  WiFiScanResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WiFiScanResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WiFiScanResult>(create);
  static WiFiScanResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get ssid => $_getN(0);
  @$pb.TagNumber(1)
  set ssid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSsid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSsid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get channel => $_getIZ(1);
  @$pb.TagNumber(2)
  set channel($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannel() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get rssi => $_getIZ(2);
  @$pb.TagNumber(3)
  set rssi($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRssi() => $_has(2);
  @$pb.TagNumber(3)
  void clearRssi() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get bssid => $_getN(3);
  @$pb.TagNumber(4)
  set bssid($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBssid() => $_has(3);
  @$pb.TagNumber(4)
  void clearBssid() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.WifiAuthMode get auth => $_getN(4);
  @$pb.TagNumber(5)
  set auth($0.WifiAuthMode value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAuth() => $_has(4);
  @$pb.TagNumber(5)
  void clearAuth() => $_clearField(5);
}

class RespScanResult extends $pb.GeneratedMessage {
  factory RespScanResult({
    $core.Iterable<WiFiScanResult>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  RespScanResult._();

  factory RespScanResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RespScanResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RespScanResult',
      createEmptyInstance: create)
    ..pPM<WiFiScanResult>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: WiFiScanResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RespScanResult copyWith(void Function(RespScanResult) updates) =>
      super.copyWith((message) => updates(message as RespScanResult))
          as RespScanResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RespScanResult create() => RespScanResult._();
  @$core.override
  RespScanResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RespScanResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RespScanResult>(create);
  static RespScanResult? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WiFiScanResult> get entries => $_getList(0);
}

enum WiFiScanPayload_Payload {
  cmdScanStart,
  respScanStart,
  cmdScanStatus,
  respScanStatus,
  cmdScanResult,
  respScanResult,
  notSet
}

class WiFiScanPayload extends $pb.GeneratedMessage {
  factory WiFiScanPayload({
    WiFiScanMsgType? msg,
    $1.Status? status,
    CmdScanStart? cmdScanStart,
    RespScanStart? respScanStart,
    CmdScanStatus? cmdScanStatus,
    RespScanStatus? respScanStatus,
    CmdScanResult? cmdScanResult,
    RespScanResult? respScanResult,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    if (status != null) result.status = status;
    if (cmdScanStart != null) result.cmdScanStart = cmdScanStart;
    if (respScanStart != null) result.respScanStart = respScanStart;
    if (cmdScanStatus != null) result.cmdScanStatus = cmdScanStatus;
    if (respScanStatus != null) result.respScanStatus = respScanStatus;
    if (cmdScanResult != null) result.cmdScanResult = cmdScanResult;
    if (respScanResult != null) result.respScanResult = respScanResult;
    return result;
  }

  WiFiScanPayload._();

  factory WiFiScanPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WiFiScanPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WiFiScanPayload_Payload>
      _WiFiScanPayload_PayloadByTag = {
    10: WiFiScanPayload_Payload.cmdScanStart,
    11: WiFiScanPayload_Payload.respScanStart,
    12: WiFiScanPayload_Payload.cmdScanStatus,
    13: WiFiScanPayload_Payload.respScanStatus,
    14: WiFiScanPayload_Payload.cmdScanResult,
    15: WiFiScanPayload_Payload.respScanResult,
    0: WiFiScanPayload_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WiFiScanPayload',
      createEmptyInstance: create)
    ..oo(0, [10, 11, 12, 13, 14, 15])
    ..aE<WiFiScanMsgType>(1, _omitFieldNames ? '' : 'msg',
        enumValues: WiFiScanMsgType.values)
    ..aE<$1.Status>(2, _omitFieldNames ? '' : 'status',
        enumValues: $1.Status.values)
    ..aOM<CmdScanStart>(10, _omitFieldNames ? '' : 'cmdScanStart',
        subBuilder: CmdScanStart.create)
    ..aOM<RespScanStart>(11, _omitFieldNames ? '' : 'respScanStart',
        subBuilder: RespScanStart.create)
    ..aOM<CmdScanStatus>(12, _omitFieldNames ? '' : 'cmdScanStatus',
        subBuilder: CmdScanStatus.create)
    ..aOM<RespScanStatus>(13, _omitFieldNames ? '' : 'respScanStatus',
        subBuilder: RespScanStatus.create)
    ..aOM<CmdScanResult>(14, _omitFieldNames ? '' : 'cmdScanResult',
        subBuilder: CmdScanResult.create)
    ..aOM<RespScanResult>(15, _omitFieldNames ? '' : 'respScanResult',
        subBuilder: RespScanResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiScanPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WiFiScanPayload copyWith(void Function(WiFiScanPayload) updates) =>
      super.copyWith((message) => updates(message as WiFiScanPayload))
          as WiFiScanPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WiFiScanPayload create() => WiFiScanPayload._();
  @$core.override
  WiFiScanPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WiFiScanPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WiFiScanPayload>(create);
  static WiFiScanPayload? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  WiFiScanPayload_Payload whichPayload() =>
      _WiFiScanPayload_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  WiFiScanMsgType get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg(WiFiScanMsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($1.Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(10)
  CmdScanStart get cmdScanStart => $_getN(2);
  @$pb.TagNumber(10)
  set cmdScanStart(CmdScanStart value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCmdScanStart() => $_has(2);
  @$pb.TagNumber(10)
  void clearCmdScanStart() => $_clearField(10);
  @$pb.TagNumber(10)
  CmdScanStart ensureCmdScanStart() => $_ensure(2);

  @$pb.TagNumber(11)
  RespScanStart get respScanStart => $_getN(3);
  @$pb.TagNumber(11)
  set respScanStart(RespScanStart value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasRespScanStart() => $_has(3);
  @$pb.TagNumber(11)
  void clearRespScanStart() => $_clearField(11);
  @$pb.TagNumber(11)
  RespScanStart ensureRespScanStart() => $_ensure(3);

  @$pb.TagNumber(12)
  CmdScanStatus get cmdScanStatus => $_getN(4);
  @$pb.TagNumber(12)
  set cmdScanStatus(CmdScanStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCmdScanStatus() => $_has(4);
  @$pb.TagNumber(12)
  void clearCmdScanStatus() => $_clearField(12);
  @$pb.TagNumber(12)
  CmdScanStatus ensureCmdScanStatus() => $_ensure(4);

  @$pb.TagNumber(13)
  RespScanStatus get respScanStatus => $_getN(5);
  @$pb.TagNumber(13)
  set respScanStatus(RespScanStatus value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasRespScanStatus() => $_has(5);
  @$pb.TagNumber(13)
  void clearRespScanStatus() => $_clearField(13);
  @$pb.TagNumber(13)
  RespScanStatus ensureRespScanStatus() => $_ensure(5);

  @$pb.TagNumber(14)
  CmdScanResult get cmdScanResult => $_getN(6);
  @$pb.TagNumber(14)
  set cmdScanResult(CmdScanResult value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCmdScanResult() => $_has(6);
  @$pb.TagNumber(14)
  void clearCmdScanResult() => $_clearField(14);
  @$pb.TagNumber(14)
  CmdScanResult ensureCmdScanResult() => $_ensure(6);

  @$pb.TagNumber(15)
  RespScanResult get respScanResult => $_getN(7);
  @$pb.TagNumber(15)
  set respScanResult(RespScanResult value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasRespScanResult() => $_has(7);
  @$pb.TagNumber(15)
  void clearRespScanResult() => $_clearField(15);
  @$pb.TagNumber(15)
  RespScanResult ensureRespScanResult() => $_ensure(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
