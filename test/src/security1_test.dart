import 'package:flutter_test/flutter_test.dart';
import 'package:esp_provisioning_ble/src/security.dart';
import 'package:esp_provisioning_ble/src/security1.dart';
import 'package:esp_provisioning_ble/src/protos/generated/session.pb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Security1 initial state', () {
    test('starts in request1 state by default', () {
      final sec = Security1();
      expect(sec.sessionState, equals(SecurityState.request1));
    });

    test('accepts a custom initial state via the constructor', () {
      final sec = Security1(sessionState: SecurityState.finish);
      expect(sec.sessionState, equals(SecurityState.finish));
    });
  });

  group('Security1.setup0Request', () {
    test('returns SessionData with SecScheme1', () async {
      final result = await Security1().setup0Request();
      expect(result.secVer, equals(SecSchemeVersion.SecScheme1));
    });

    test('includes a sec1 payload', () async {
      final result = await Security1().setup0Request();
      expect(result.hasSec1(), isTrue);
    });

    test('embeds a 32-byte X25519 client public key', () async {
      final result = await Security1().setup0Request();
      expect(result.sec1.sc0.clientPubkey.length, equals(32));
    });

    test('generates a fresh keypair on each independent instance', () async {
      final r1 = await Security1().setup0Request();
      final r2 = await Security1().setup0Request();
      // Two independently generated X25519 keys are astronomically unlikely to collide.
      expect(r1.sec1.sc0.clientPubkey, isNot(equals(r2.sec1.sc0.clientPubkey)));
    });
  });

  group('Security1.securitySession state machine', () {
    test('first call advances state from request1 to response1Request2', () async {
      final sec = Security1();
      await sec.securitySession(SessionData());
      expect(sec.sessionState, equals(SecurityState.response1Request2));
    });

    test('first call returns non-null SessionData (setup0Request output)', () async {
      final sec = Security1();
      final result = await sec.securitySession(SessionData());
      expect(result, isNotNull);
      expect(result!.secVer, equals(SecSchemeVersion.SecScheme1));
    });

    test('throws an Exception when called in the finish state', () async {
      final sec = Security1(sessionState: SecurityState.finish);
      expect(
        () => sec.securitySession(SessionData()),
        throwsA(isA<Exception>()),
      );
    });
  });
}
