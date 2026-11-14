// Golden wire-format tests for the generated protobuf bindings.
//
// The expected bytes were produced once by the protobuf 3 bindings shipped in
// 1.1.0, before any regeneration, and are pinned here so that upgrading
// protobuf or protoc_plugin cannot silently change what goes over BLE. Do not update a literal to make a test pass: a mismatch means the
// regenerated code no longer speaks the same protocol as before.
//
// Encoding tests build each message the way EspProv and Security1 do.
// Decoding tests start from bytes written by hand as an ESP-IDF device sends
// them (protobuf-c omits proto3 scalars that hold their default value).
//
// The messages are built with plain assignments rather than multi-line
// cascades so that this file formats the same under every Dart language
// version, and therefore never has to change.

import 'package:esp_provisioning_ble/src/protos/generated/constants.pbenum.dart';
import 'package:esp_provisioning_ble/src/protos/generated/sec0.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/sec1.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/session.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_config.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_constants.pb.dart';
import 'package:esp_provisioning_ble/src/protos/generated/wifi_scan.pb.dart';
import 'package:flutter_test/flutter_test.dart';

String _hex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

List<int> _bytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}

/// 0x00, 0x01, ..., 0x1f: a stand-in for a 32-byte Curve25519 public key.
final _clientPubkey = List<int>.generate(32, (i) => i);

/// 0xa0, 0xa1, ..., 0xbf: a stand-in for the encrypted device public key.
final _clientVerifyData = List<int>.generate(32, (i) => 0xa0 + i);

const _bssid = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66];

void main() {
  group('encodes client commands', () {
    test('SessionData with Sec1 SessionCmd0 (Security1.setup0Request)', () {
      final sc0 = SessionCmd0();
      sc0.clientPubkey = _clientPubkey;
      final sec1 = Sec1Payload();
      sec1.sc0 = sc0;
      final message = SessionData();
      message.secVer = SecSchemeVersion.SecScheme1;
      message.sec1 = sec1;

      expect(
        _hex(message.writeToBuffer()),
        '10015a25a201220a20'
        '000102030405060708090a0b0c0d0e0f'
        '101112131415161718191a1b1c1d1e1f',
      );
    });

    test('SessionData with Sec1 SessionCmd1 (Security1.setup1Request)', () {
      final sc1 = SessionCmd1();
      sc1.clientVerifyData = _clientVerifyData;
      final sec1 = Sec1Payload();
      sec1.msg = Sec1MsgType.Session_Command1;
      sec1.sc1 = sc1;
      final message = SessionData();
      message.secVer = SecSchemeVersion.SecScheme1;
      message.sec1 = sec1;

      expect(
        _hex(message.writeToBuffer()),
        '10015a270802b201221220'
        'a0a1a2a3a4a5a6a7a8a9aaabacadaeaf'
        'b0b1b2b3b4b5b6b7b8b9babbbcbdbebf',
      );
    });

    test('SessionData with Sec0 S0SessionCmd', () {
      final sec0 = Sec0Payload();
      sec0.msg = Sec0MsgType.S0_Session_Command;
      sec0.sc = S0SessionCmd();
      final message = SessionData();
      message.secVer = SecSchemeVersion.SecScheme0;
      message.sec0 = sec0;

      expect(_hex(message.writeToBuffer()), '100052050800a20100');
    });

    test('WiFiScanPayload with the default CmdScanStart (EspProv.scan)', () {
      final scanStart = CmdScanStart();
      scanStart.blocking = true;
      scanStart.passive = false;
      scanStart.groupChannels = 5;
      scanStart.periodMs = 0;
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanStart;
      message.cmdScanStart = scanStart;

      expect(_hex(message.writeToBuffer()), '080052080801100018052000');
    });

    test('WiFiScanPayload with a non-default CmdScanStart', () {
      final scanStart = CmdScanStart();
      scanStart.blocking = false;
      scanStart.passive = true;
      scanStart.groupChannels = 3;
      scanStart.periodMs = 120;
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanStart;
      message.cmdScanStart = scanStart;

      expect(_hex(message.writeToBuffer()), '080052080800100118032078');
    });

    test('WiFiScanPayload for CmdScanStatus as EspProv sends it', () {
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanStatus;

      expect(_hex(message.writeToBuffer()), '0802');
    });

    test('WiFiScanPayload with an explicit empty CmdScanStatus', () {
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanStatus;
      message.cmdScanStatus = CmdScanStatus();

      expect(_hex(message.writeToBuffer()), '08026200');
    });

    test('WiFiScanPayload with CmdScanResult', () {
      final scanResult = CmdScanResult();
      scanResult.startIndex = 4;
      scanResult.count = 4;
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanResult;
      message.cmdScanResult = scanResult;

      expect(_hex(message.writeToBuffer()), '0804720408041004');
    });

    test('WiFiScanPayload with CmdScanResult at its defaults', () {
      final scanResult = CmdScanResult();
      scanResult.startIndex = 0;
      scanResult.count = 0;
      final message = WiFiScanPayload();
      message.msg = WiFiScanMsgType.TypeCmdScanResult;
      message.cmdScanResult = scanResult;

      expect(_hex(message.writeToBuffer()), '0804720408001000');
    });

    test('WiFiConfigPayload with CmdSetConfig and every field set', () {
      final setConfig = CmdSetConfig();
      setConfig.ssid = 'MyWiFi'.codeUnits;
      setConfig.passphrase = 'secret12'.codeUnits;
      setConfig.bssid = [0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff];
      setConfig.channel = 6;
      final message = WiFiConfigPayload();
      message.msg = WiFiConfigMsgType.TypeCmdSetConfig;
      message.cmdSetConfig = setConfig;

      expect(
        _hex(message.writeToBuffer()),
        '0802621c'
        '0a064d7957694669'
        '12087365637265743132'
        '1a06aabbccddeeff'
        '2006',
      );
    });

    test('WiFiConfigPayload with CmdSetConfig as EspProv sends it', () {
      final setConfig = CmdSetConfig();
      setConfig.ssid = 'MyWiFi'.codeUnits;
      setConfig.passphrase = 'secret12'.codeUnits;
      final message = WiFiConfigPayload();
      message.msg = WiFiConfigMsgType.TypeCmdSetConfig;
      message.cmdSetConfig = setConfig;

      expect(
        _hex(message.writeToBuffer()),
        '08026212'
        '0a064d7957694669'
        '12087365637265743132',
      );
    });

    test('WiFiConfigPayload for CmdApplyConfig as EspProv sends it', () {
      final message = WiFiConfigPayload();
      message.msg = WiFiConfigMsgType.TypeCmdApplyConfig;

      expect(_hex(message.writeToBuffer()), '0804');
    });

    test('WiFiConfigPayload with an explicit empty CmdApplyConfig', () {
      final message = WiFiConfigPayload();
      message.msg = WiFiConfigMsgType.TypeCmdApplyConfig;
      message.cmdApplyConfig = CmdApplyConfig();

      expect(_hex(message.writeToBuffer()), '08047200');
    });

    test('WiFiConfigPayload with CmdGetStatus (EspProv.getStatus)', () {
      final message = WiFiConfigPayload();
      message.msg = WiFiConfigMsgType.TypeCmdGetStatus;
      message.cmdGetStatus = CmdGetStatus();

      expect(_hex(message.writeToBuffer()), '08005200');
    });
  });

  group('decodes device responses', () {
    test('SessionData with Sec1 SessionResp0', () {
      final bytes = _bytes(
        '10015a390801aa01341220'
        '404142434445464748494a4b4c4d4e4f'
        '505152535455565758595a5b5c5d5e5f'
        '1a10'
        '808182838485868788898a8b8c8d8e8f',
      );
      final message = SessionData.fromBuffer(bytes);

      expect(message.secVer, SecSchemeVersion.SecScheme1);
      expect(message.whichProto(), SessionData_Proto.sec1);
      expect(message.sec1.msg, Sec1MsgType.Session_Response0);
      expect(message.sec1.whichPayload(), Sec1Payload_Payload.sr0);
      final sr0 = message.sec1.sr0;
      expect(sr0.status, Status.Success);
      expect(sr0.devicePubkey, List<int>.generate(32, (i) => 0x40 + i));
      expect(sr0.deviceRandom, List<int>.generate(16, (i) => 0x80 + i));
    });

    test('SessionData with Sec1 SessionResp1', () {
      final bytes = _bytes(
        '10015a270803ba01221a20'
        'c0c1c2c3c4c5c6c7c8c9cacbcccdcecf'
        'd0d1d2d3d4d5d6d7d8d9dadbdcdddedf',
      );
      final message = SessionData.fromBuffer(bytes);

      expect(message.secVer, SecSchemeVersion.SecScheme1);
      expect(message.sec1.msg, Sec1MsgType.Session_Response1);
      expect(message.sec1.whichPayload(), Sec1Payload_Payload.sr1);
      final sr1 = message.sec1.sr1;
      expect(sr1.status, Status.Success);
      expect(sr1.deviceVerifyData, List<int>.generate(32, (i) => 0xc0 + i));
    });

    test('WiFiScanPayload with RespScanStatus', () {
      final message = WiFiScanPayload.fromBuffer(_bytes('08036a0408011003'));

      expect(message.msg, WiFiScanMsgType.TypeRespScanStatus);
      expect(message.status, Status.Success);
      expect(message.whichPayload(), WiFiScanPayload_Payload.respScanStatus);
      expect(message.respScanStatus.scanFinished, isTrue);
      expect(message.respScanStatus.resultCount, 3);
    });

    test('WiFiScanPayload with RespScanResult entries', () {
      final bytes = _bytes(
        '08057a34'
        // WPA2_PSK entry with every field set.
        '0a1d'
        '0a04486f6d65'
        '1006'
        '18d6ffffffffffffffff01'
        '2206112233445566'
        '2803'
        // Open entry: auth and bssid are omitted on the wire.
        '0a13'
        '0a0443616665'
        '100b'
        '18b0ffffffffffffffff01',
      );
      final message = WiFiScanPayload.fromBuffer(bytes);

      expect(message.msg, WiFiScanMsgType.TypeRespScanResult);
      expect(message.whichPayload(), WiFiScanPayload_Payload.respScanResult);
      final entries = message.respScanResult.entries;
      expect(entries, hasLength(2));

      expect(entries[0].ssid, 'Home'.codeUnits);
      expect(entries[0].channel, 6);
      expect(entries[0].rssi, -42);
      expect(entries[0].bssid, _bssid);
      expect(entries[0].auth, WifiAuthMode.WPA2_PSK);

      expect(entries[1].ssid, 'Cafe'.codeUnits);
      expect(entries[1].channel, 11);
      expect(entries[1].rssi, -80);
      expect(entries[1].bssid, isEmpty);
      expect(entries[1].hasAuth(), isFalse);
      expect(entries[1].auth, WifiAuthMode.Open);
    });

    test('WiFiConfigPayload with RespGetStatus in the connected state', () {
      final bytes = _bytes(
        '08015a22'
        // sta_state Connected (0) is omitted; the connected state follows.
        '5a20'
        '0a0c3139322e3136382e312e3432'
        '1003'
        '1a04486f6d65'
        '2206112233445566'
        '2806',
      );
      final message = WiFiConfigPayload.fromBuffer(bytes);

      expect(message.msg, WiFiConfigMsgType.TypeRespGetStatus);
      expect(message.whichPayload(), WiFiConfigPayload_Payload.respGetStatus);
      final status = message.respGetStatus;
      expect(status.status, Status.Success);
      expect(status.staState, WifiStationState.Connected);
      expect(status.whichState(), RespGetStatus_State.connected);
      expect(status.connected.ip4Addr, '192.168.1.42');
      expect(status.connected.authMode, WifiAuthMode.WPA2_PSK);
      expect(status.connected.ssid, 'Home'.codeUnits);
      expect(status.connected.bssid, _bssid);
      expect(status.connected.channel, 6);
    });

    test('WiFiConfigPayload with RespGetStatus failed: network not found', () {
      final bytes = _bytes('08015a0410035001');
      final message = WiFiConfigPayload.fromBuffer(bytes);

      final status = message.respGetStatus;
      expect(status.staState, WifiStationState.ConnectionFailed);
      expect(status.whichState(), RespGetStatus_State.failReason);
      expect(status.failReason, WifiConnectFailedReason.NetworkNotFound);
    });

    test('WiFiConfigPayload with RespGetStatus failed: auth error', () {
      // fail_reason lives in a oneof, so AuthError (0) is still sent.
      final bytes = _bytes('08015a0410035000');
      final message = WiFiConfigPayload.fromBuffer(bytes);

      final status = message.respGetStatus;
      expect(status.staState, WifiStationState.ConnectionFailed);
      expect(status.whichState(), RespGetStatus_State.failReason);
      expect(status.failReason, WifiConnectFailedReason.AuthError);
    });
  });
}
