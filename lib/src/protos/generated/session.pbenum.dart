// This is a generated file - do not edit.
//
// Generated from session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Allowed values for the type of security
/// being used in a protocomm session
class SecSchemeVersion extends $pb.ProtobufEnum {
  static const SecSchemeVersion SecScheme0 =
      SecSchemeVersion._(0, _omitEnumNames ? '' : 'SecScheme0');
  static const SecSchemeVersion SecScheme1 =
      SecSchemeVersion._(1, _omitEnumNames ? '' : 'SecScheme1');

  static const $core.List<SecSchemeVersion> values = <SecSchemeVersion>[
    SecScheme0,
    SecScheme1,
  ];

  static final $core.List<SecSchemeVersion?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SecSchemeVersion? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SecSchemeVersion._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
