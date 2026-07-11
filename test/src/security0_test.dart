import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:esp_provisioning_ble/src/security.dart';
import 'package:esp_provisioning_ble/src/security0.dart';
import 'package:esp_provisioning_ble/src/protos/generated/session.pb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Security0 encrypt/decrypt', () {
    test('encrypt returns the input unchanged', () async {
      final sec = Security0();
      final data = Uint8List.fromList([1, 2, 3, 4]);
      final result = await sec.encrypt(data);
      expect(result, equals(data));
    });

    test('decrypt returns the input unchanged', () async {
      final sec = Security0();
      final data = Uint8List.fromList([5, 6, 7, 8]);
      final result = await sec.decrypt(data);
      expect(result, equals(data));
    });
  });

  group('Security0.securitySession step0Request', () {
    test('returns SessionData with SecScheme0', () async {
      final sec = Security0();
      final result = await sec.securitySession(null);
      expect(result, isNotNull);
      expect(result!.secVer, equals(SecSchemeVersion.SecScheme0));
    });

    test('includes a sec0 payload', () async {
      final sec = Security0();
      final result = await sec.securitySession(null);
      expect(result!.hasSec0(), isTrue);
    });

    test('advances sessionState to step0Response', () async {
      final sec = Security0();
      await sec.securitySession(null);
      expect(sec.sessionState, equals(Security0State.step0Response));
    });
  });

  group('Security0.securitySession step0Response', () {
    test('returns null for a valid SecScheme0 response', () async {
      final sec = Security0();
      await sec.securitySession(null); // step0Request
      final response = SessionData()..secVer = SecSchemeVersion.SecScheme0;
      final result = await sec.securitySession(response);
      expect(result, isNull);
    });

    test('advances sessionState to finish', () async {
      final sec = Security0();
      await sec.securitySession(null); // step0Request
      final response = SessionData()..secVer = SecSchemeVersion.SecScheme0;
      await sec.securitySession(response);
      expect(sec.sessionState, equals(Security0State.finish));
    });

    test('returns null when called again after handshake is complete', () async {
      final sec = Security0();
      await sec.securitySession(null); // step0Request
      final response = SessionData()..secVer = SecSchemeVersion.SecScheme0;
      await sec.securitySession(response); // step0Response -> finish
      final result = await sec.securitySession(null); // idempotent
      expect(result, isNull);
    });

    test('throws when responseData is null', () async {
      final sec = Security0(sessionState: Security0State.step0Response);
      expect(
        () => sec.securitySession(null),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when secVer does not match SecScheme0', () async {
      final sec = Security0(sessionState: Security0State.step0Response);
      final response = SessionData()..secVer = SecSchemeVersion.SecScheme1;
      expect(
        () => sec.securitySession(response),
        throwsA(isA<Exception>()),
      );
    });
  });
}
