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

/// A message must be of type Cmd or Resp
class Sec0MsgType extends $pb.ProtobufEnum {
  static const Sec0MsgType S0_Session_Command =
      Sec0MsgType._(0, _omitEnumNames ? '' : 'S0_Session_Command');
  static const Sec0MsgType S0_Session_Response =
      Sec0MsgType._(1, _omitEnumNames ? '' : 'S0_Session_Response');

  static const $core.List<Sec0MsgType> values = <Sec0MsgType>[
    S0_Session_Command,
    S0_Session_Response,
  ];

  static final $core.List<Sec0MsgType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Sec0MsgType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Sec0MsgType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
