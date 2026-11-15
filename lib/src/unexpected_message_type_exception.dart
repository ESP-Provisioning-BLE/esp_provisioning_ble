/// Thrown when a device answers with a message of a different type than the
/// one the provisioning flow expects at that point.
///
/// It is thrown by `EspProv.startScanResponse`, `EspProv.scanStatusResponse`
/// and `EspProv.scanResultResponse` (and therefore by `EspProv.scan` and
/// `EspProv.startScanWiFi`) when the decrypted scan payload carries a message
/// type other than the expected response. Typical causes are a corrupted or
/// out-of-order BLE message, or a device running unexpected firmware.
///
/// The exception implements [Exception], so existing `on Exception` and
/// `catch (e)` handlers keep catching it, and [toString] returns exactly the
/// text of the plain `Exception` thrown by earlier versions
/// (`Exception: Invalid expected message type ...`).
///
/// The fields only use core Dart types, so they do not depend on the
/// protobuf-generated classes of this package.
///
/// ```dart
/// try {
///   await prov.startScanWiFi();
/// } on UnexpectedMessageTypeException catch (e) {
///   print('Expected ${e.expectedType}, got ${e.actualType}');
/// }
/// ```
class UnexpectedMessageTypeException implements Exception {
  /// Creates the exception.
  const UnexpectedMessageTypeException({
    required this.expectedType,
    required this.expectedValue,
    required this.actualType,
    required this.actualValue,
    required this.payload,
  });

  /// Protocol name of the message type that was expected, such as
  /// `TypeRespScanStatus`.
  final String expectedType;

  /// Numeric value, on the wire, of the message type that was expected.
  final int expectedValue;

  /// Protocol name of the message type that was received, such as
  /// `TypeRespScanStart`.
  final String actualType;

  /// Numeric value, on the wire, of the message type that was received.
  final int actualValue;

  /// Text rendering of the message that was received, for logging. Its format
  /// is not part of the public contract and may change.
  final String payload;

  @override
  String toString() => 'Exception: Invalid expected message type $payload';
}
