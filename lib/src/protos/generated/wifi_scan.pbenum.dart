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

class WiFiScanMsgType extends $pb.ProtobufEnum {
  static const WiFiScanMsgType TypeCmdScanStart =
      WiFiScanMsgType._(0, _omitEnumNames ? '' : 'TypeCmdScanStart');
  static const WiFiScanMsgType TypeRespScanStart =
      WiFiScanMsgType._(1, _omitEnumNames ? '' : 'TypeRespScanStart');
  static const WiFiScanMsgType TypeCmdScanStatus =
      WiFiScanMsgType._(2, _omitEnumNames ? '' : 'TypeCmdScanStatus');
  static const WiFiScanMsgType TypeRespScanStatus =
      WiFiScanMsgType._(3, _omitEnumNames ? '' : 'TypeRespScanStatus');
  static const WiFiScanMsgType TypeCmdScanResult =
      WiFiScanMsgType._(4, _omitEnumNames ? '' : 'TypeCmdScanResult');
  static const WiFiScanMsgType TypeRespScanResult =
      WiFiScanMsgType._(5, _omitEnumNames ? '' : 'TypeRespScanResult');

  static const $core.List<WiFiScanMsgType> values = <WiFiScanMsgType>[
    TypeCmdScanStart,
    TypeRespScanStart,
    TypeCmdScanStatus,
    TypeRespScanStatus,
    TypeCmdScanResult,
    TypeRespScanResult,
  ];

  static final $core.List<WiFiScanMsgType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static WiFiScanMsgType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WiFiScanMsgType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
