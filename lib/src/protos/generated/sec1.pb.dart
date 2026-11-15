// This is a generated file - do not edit.
//
// Generated from sec1.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $0;
import 'sec1.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sec1.pbenum.dart';

/// Data structure of Session command1 packet
class SessionCmd1 extends $pb.GeneratedMessage {
  factory SessionCmd1({
    $core.List<$core.int>? clientVerifyData,
  }) {
    final result = create();
    if (clientVerifyData != null) result.clientVerifyData = clientVerifyData;
    return result;
  }

  SessionCmd1._();

  factory SessionCmd1.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionCmd1.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionCmd1',
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'clientVerifyData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionCmd1 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionCmd1 copyWith(void Function(SessionCmd1) updates) =>
      super.copyWith((message) => updates(message as SessionCmd1))
          as SessionCmd1;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionCmd1 create() => SessionCmd1._();
  @$core.override
  SessionCmd1 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionCmd1 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionCmd1>(create);
  static SessionCmd1? _defaultInstance;

  @$pb.TagNumber(2)
  $core.List<$core.int> get clientVerifyData => $_getN(0);
  @$pb.TagNumber(2)
  set clientVerifyData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(2)
  $core.bool hasClientVerifyData() => $_has(0);
  @$pb.TagNumber(2)
  void clearClientVerifyData() => $_clearField(2);
}

/// Data structure of Session response1 packet
class SessionResp1 extends $pb.GeneratedMessage {
  factory SessionResp1({
    $0.Status? status,
    $core.List<$core.int>? deviceVerifyData,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (deviceVerifyData != null) result.deviceVerifyData = deviceVerifyData;
    return result;
  }

  SessionResp1._();

  factory SessionResp1.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionResp1.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionResp1',
      createEmptyInstance: create)
    ..aE<$0.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $0.Status.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'deviceVerifyData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionResp1 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionResp1 copyWith(void Function(SessionResp1) updates) =>
      super.copyWith((message) => updates(message as SessionResp1))
          as SessionResp1;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionResp1 create() => SessionResp1._();
  @$core.override
  SessionResp1 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionResp1 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionResp1>(create);
  static SessionResp1? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($0.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deviceVerifyData => $_getN(1);
  @$pb.TagNumber(3)
  set deviceVerifyData($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceVerifyData() => $_has(1);
  @$pb.TagNumber(3)
  void clearDeviceVerifyData() => $_clearField(3);
}

/// Data structure of Session command0 packet
class SessionCmd0 extends $pb.GeneratedMessage {
  factory SessionCmd0({
    $core.List<$core.int>? clientPubkey,
  }) {
    final result = create();
    if (clientPubkey != null) result.clientPubkey = clientPubkey;
    return result;
  }

  SessionCmd0._();

  factory SessionCmd0.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionCmd0.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionCmd0',
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'clientPubkey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionCmd0 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionCmd0 copyWith(void Function(SessionCmd0) updates) =>
      super.copyWith((message) => updates(message as SessionCmd0))
          as SessionCmd0;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionCmd0 create() => SessionCmd0._();
  @$core.override
  SessionCmd0 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionCmd0 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionCmd0>(create);
  static SessionCmd0? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get clientPubkey => $_getN(0);
  @$pb.TagNumber(1)
  set clientPubkey($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientPubkey() => $_clearField(1);
}

/// Data structure of Session response0 packet
class SessionResp0 extends $pb.GeneratedMessage {
  factory SessionResp0({
    $0.Status? status,
    $core.List<$core.int>? devicePubkey,
    $core.List<$core.int>? deviceRandom,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (devicePubkey != null) result.devicePubkey = devicePubkey;
    if (deviceRandom != null) result.deviceRandom = deviceRandom;
    return result;
  }

  SessionResp0._();

  factory SessionResp0.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionResp0.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionResp0',
      createEmptyInstance: create)
    ..aE<$0.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $0.Status.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'devicePubkey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'deviceRandom', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionResp0 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionResp0 copyWith(void Function(SessionResp0) updates) =>
      super.copyWith((message) => updates(message as SessionResp0))
          as SessionResp0;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionResp0 create() => SessionResp0._();
  @$core.override
  SessionResp0 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionResp0 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionResp0>(create);
  static SessionResp0? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($0.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get devicePubkey => $_getN(1);
  @$pb.TagNumber(2)
  set devicePubkey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDevicePubkey() => $_has(1);
  @$pb.TagNumber(2)
  void clearDevicePubkey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deviceRandom => $_getN(2);
  @$pb.TagNumber(3)
  set deviceRandom($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceRandom() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceRandom() => $_clearField(3);
}

enum Sec1Payload_Payload { sc0, sr0, sc1, sr1, notSet }

/// Payload structure of session data
class Sec1Payload extends $pb.GeneratedMessage {
  factory Sec1Payload({
    Sec1MsgType? msg,
    SessionCmd0? sc0,
    SessionResp0? sr0,
    SessionCmd1? sc1,
    SessionResp1? sr1,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    if (sc0 != null) result.sc0 = sc0;
    if (sr0 != null) result.sr0 = sr0;
    if (sc1 != null) result.sc1 = sc1;
    if (sr1 != null) result.sr1 = sr1;
    return result;
  }

  Sec1Payload._();

  factory Sec1Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Sec1Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Sec1Payload_Payload>
      _Sec1Payload_PayloadByTag = {
    20: Sec1Payload_Payload.sc0,
    21: Sec1Payload_Payload.sr0,
    22: Sec1Payload_Payload.sc1,
    23: Sec1Payload_Payload.sr1,
    0: Sec1Payload_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sec1Payload',
      createEmptyInstance: create)
    ..oo(0, [20, 21, 22, 23])
    ..aE<Sec1MsgType>(1, _omitFieldNames ? '' : 'msg',
        enumValues: Sec1MsgType.values)
    ..aOM<SessionCmd0>(20, _omitFieldNames ? '' : 'sc0',
        subBuilder: SessionCmd0.create)
    ..aOM<SessionResp0>(21, _omitFieldNames ? '' : 'sr0',
        subBuilder: SessionResp0.create)
    ..aOM<SessionCmd1>(22, _omitFieldNames ? '' : 'sc1',
        subBuilder: SessionCmd1.create)
    ..aOM<SessionResp1>(23, _omitFieldNames ? '' : 'sr1',
        subBuilder: SessionResp1.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sec1Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sec1Payload copyWith(void Function(Sec1Payload) updates) =>
      super.copyWith((message) => updates(message as Sec1Payload))
          as Sec1Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sec1Payload create() => Sec1Payload._();
  @$core.override
  Sec1Payload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Sec1Payload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Sec1Payload>(create);
  static Sec1Payload? _defaultInstance;

  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  Sec1Payload_Payload whichPayload() =>
      _Sec1Payload_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Sec1MsgType get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg(Sec1MsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(20)
  SessionCmd0 get sc0 => $_getN(1);
  @$pb.TagNumber(20)
  set sc0(SessionCmd0 value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSc0() => $_has(1);
  @$pb.TagNumber(20)
  void clearSc0() => $_clearField(20);
  @$pb.TagNumber(20)
  SessionCmd0 ensureSc0() => $_ensure(1);

  @$pb.TagNumber(21)
  SessionResp0 get sr0 => $_getN(2);
  @$pb.TagNumber(21)
  set sr0(SessionResp0 value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasSr0() => $_has(2);
  @$pb.TagNumber(21)
  void clearSr0() => $_clearField(21);
  @$pb.TagNumber(21)
  SessionResp0 ensureSr0() => $_ensure(2);

  @$pb.TagNumber(22)
  SessionCmd1 get sc1 => $_getN(3);
  @$pb.TagNumber(22)
  set sc1(SessionCmd1 value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasSc1() => $_has(3);
  @$pb.TagNumber(22)
  void clearSc1() => $_clearField(22);
  @$pb.TagNumber(22)
  SessionCmd1 ensureSc1() => $_ensure(3);

  @$pb.TagNumber(23)
  SessionResp1 get sr1 => $_getN(4);
  @$pb.TagNumber(23)
  set sr1(SessionResp1 value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasSr1() => $_has(4);
  @$pb.TagNumber(23)
  void clearSr1() => $_clearField(23);
  @$pb.TagNumber(23)
  SessionResp1 ensureSr1() => $_ensure(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
