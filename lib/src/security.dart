import 'dart:typed_data';

import 'protos/generated/session.pb.dart';

/// Represents the security state of an established session.
enum SecurityState {
  request1,
  response1Request2,
  response2,
  finish,
}

abstract class ProvSecurity {
  /// Encrypts the given data using the security protocol.
  ///
  /// The `data` parameter is an with data to be encrypted.
  ///
  /// Returns a `Future` that completes with the encrypted data.
  Future<Uint8List> encrypt(Uint8List data);

  /// Decrypts the given data using the security protocol.
  ///
  /// The `data` parameter is the data to be decrypted.
  ///
  /// Returns a Future that completes with the decrypted data.
  Future<Uint8List> decrypt(Uint8List data);

  /// Initiates a security session with the provided response data.
  ///
  /// The `responseData` parameter is the response data received from the peer.
  ///
  /// Returns a `Future` that completes with the security session data, or
  /// `null` if the session cannot be established.
  Future<SessionData?> securitySession(SessionData responseData);
}
