import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp_provisioning_ble/src/crypt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('esp_provisioning_ble');

  // Key used by the mock handler; updated on each 'init' call.
  List<int> mockKey = [];

  setUp(() {
    mockKey = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'init':
          mockKey = List<int>.from(
            (call.arguments as Map)['key'] as Uint8List,
          );
          return true;
        case 'crypt':
          final data = (call.arguments as Map)['data'] as Uint8List;
          if (mockKey.isEmpty) return data;
          // Simulate a symmetric XOR stream cipher using the key bytes.
          return Uint8List.fromList(
            List.generate(
              data.length,
              (i) => data[i] ^ mockKey[i % mockKey.length],
            ),
          );
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Crypt.init', () {
    test('returns true on success', () async {
      final crypt = Crypt();
      final key = Uint8List(32)..fillRange(0, 32, 0x42);
      final iv = Uint8List(16)..fillRange(0, 16, 0x01);
      expect(await crypt.init(key, iv), isTrue);
    });
  });

  group('Crypt.crypt', () {
    test('encrypt/decrypt round-trip returns original data', () async {
      final crypt = Crypt();
      await crypt.init(
        Uint8List(32)..fillRange(0, 32, 0xAB),
        Uint8List(16),
      );
      final plaintext = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final encrypted = await crypt.crypt(plaintext);
      final decrypted = await crypt.crypt(encrypted);
      expect(decrypted, equals(plaintext));
    });

    test('output has same length as input', () async {
      final crypt = Crypt();
      await crypt.init(Uint8List(32), Uint8List(16));
      final data = Uint8List(64);
      final result = await crypt.crypt(data);
      expect(result.length, equals(64));
    });

    test('encrypting with different keys produces different output', () async {
      final crypt = Crypt();
      final plaintext = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
      final iv = Uint8List(16);

      await crypt.init(Uint8List(32)..fillRange(0, 32, 0x11), iv);
      final encrypted1 = await crypt.crypt(plaintext);

      await crypt.init(Uint8List(32)..fillRange(0, 32, 0x22), iv);
      final encrypted2 = await crypt.crypt(plaintext);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('decrypting with the wrong key produces incorrect plaintext', () async {
      final crypt = Crypt();
      final plaintext = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
      final iv = Uint8List(16);

      await crypt.init(Uint8List(32)..fillRange(0, 32, 0xAA), iv);
      final encrypted = await crypt.crypt(plaintext);

      await crypt.init(Uint8List(32)..fillRange(0, 32, 0xBB), iv);
      final wrongDecrypted = await crypt.crypt(encrypted);

      expect(wrongDecrypted, isNot(equals(plaintext)));
    });
  });
}
