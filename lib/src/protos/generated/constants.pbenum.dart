// This is a generated file - do not edit.
//
// Generated from constants.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Allowed values for the status
/// of a protocomm instance
class Status extends $pb.ProtobufEnum {
  static const Status Success = Status._(0, _omitEnumNames ? '' : 'Success');
  static const Status InvalidSecScheme =
      Status._(1, _omitEnumNames ? '' : 'InvalidSecScheme');
  static const Status InvalidProto =
      Status._(2, _omitEnumNames ? '' : 'InvalidProto');
  static const Status TooManySessions =
      Status._(3, _omitEnumNames ? '' : 'TooManySessions');
  static const Status InvalidArgument =
      Status._(4, _omitEnumNames ? '' : 'InvalidArgument');
  static const Status InternalError =
      Status._(5, _omitEnumNames ? '' : 'InternalError');
  static const Status CryptoError =
      Status._(6, _omitEnumNames ? '' : 'CryptoError');
  static const Status InvalidSession =
      Status._(7, _omitEnumNames ? '' : 'InvalidSession');

  static const $core.List<Status> values = <Status>[
    Success,
    InvalidSecScheme,
    InvalidProto,
    TooManySessions,
    InvalidArgument,
    InternalError,
    CryptoError,
    InvalidSession,
  ];

  static final $core.List<Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Status._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
