// This is a generated file - do not edit.
//
// Generated from sec0.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $0;
import 'sec0.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sec0.pbenum.dart';

/// Data structure of Session command/request packet
class S0SessionCmd extends $pb.GeneratedMessage {
  factory S0SessionCmd() => create();

  S0SessionCmd._();

  factory S0SessionCmd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory S0SessionCmd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'S0SessionCmd',
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S0SessionCmd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S0SessionCmd copyWith(void Function(S0SessionCmd) updates) =>
      super.copyWith((message) => updates(message as S0SessionCmd))
          as S0SessionCmd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static S0SessionCmd create() => S0SessionCmd._();
  @$core.override
  S0SessionCmd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static S0SessionCmd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<S0SessionCmd>(create);
  static S0SessionCmd? _defaultInstance;
}

/// Data structure of Session response packet
class S0SessionResp extends $pb.GeneratedMessage {
  factory S0SessionResp({
    $0.Status? status,
  }) {
    final result = create();
    if (status != null) result.status = status;
    return result;
  }

  S0SessionResp._();

  factory S0SessionResp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory S0SessionResp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'S0SessionResp',
      createEmptyInstance: create)
    ..aE<$0.Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: $0.Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S0SessionResp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S0SessionResp copyWith(void Function(S0SessionResp) updates) =>
      super.copyWith((message) => updates(message as S0SessionResp))
          as S0SessionResp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static S0SessionResp create() => S0SessionResp._();
  @$core.override
  S0SessionResp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static S0SessionResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<S0SessionResp>(create);
  static S0SessionResp? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($0.Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
}

enum Sec0Payload_Payload { sc, sr, notSet }

/// Payload structure of session data
class Sec0Payload extends $pb.GeneratedMessage {
  factory Sec0Payload({
    Sec0MsgType? msg,
    S0SessionCmd? sc,
    S0SessionResp? sr,
  }) {
    final result = create();
    if (msg != null) result.msg = msg;
    if (sc != null) result.sc = sc;
    if (sr != null) result.sr = sr;
    return result;
  }

  Sec0Payload._();

  factory Sec0Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Sec0Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Sec0Payload_Payload>
      _Sec0Payload_PayloadByTag = {
    20: Sec0Payload_Payload.sc,
    21: Sec0Payload_Payload.sr,
    0: Sec0Payload_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sec0Payload',
      createEmptyInstance: create)
    ..oo(0, [20, 21])
    ..aE<Sec0MsgType>(1, _omitFieldNames ? '' : 'msg',
        enumValues: Sec0MsgType.values)
    ..aOM<S0SessionCmd>(20, _omitFieldNames ? '' : 'sc',
        subBuilder: S0SessionCmd.create)
    ..aOM<S0SessionResp>(21, _omitFieldNames ? '' : 'sr',
        subBuilder: S0SessionResp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sec0Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sec0Payload copyWith(void Function(Sec0Payload) updates) =>
      super.copyWith((message) => updates(message as Sec0Payload))
          as Sec0Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sec0Payload create() => Sec0Payload._();
  @$core.override
  Sec0Payload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Sec0Payload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Sec0Payload>(create);
  static Sec0Payload? _defaultInstance;

  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  Sec0Payload_Payload whichPayload() =>
      _Sec0Payload_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Sec0MsgType get msg => $_getN(0);
  @$pb.TagNumber(1)
  set msg(Sec0MsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField(1);

  @$pb.TagNumber(20)
  S0SessionCmd get sc => $_getN(1);
  @$pb.TagNumber(20)
  set sc(S0SessionCmd value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSc() => $_has(1);
  @$pb.TagNumber(20)
  void clearSc() => $_clearField(20);
  @$pb.TagNumber(20)
  S0SessionCmd ensureSc() => $_ensure(1);

  @$pb.TagNumber(21)
  S0SessionResp get sr => $_getN(2);
  @$pb.TagNumber(21)
  set sr(S0SessionResp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasSr() => $_has(2);
  @$pb.TagNumber(21)
  void clearSr() => $_clearField(21);
  @$pb.TagNumber(21)
  S0SessionResp ensureSr() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
