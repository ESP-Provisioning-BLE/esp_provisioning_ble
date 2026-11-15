import 'dart:typed_data';

import 'protos/generated/session.pb.dart';

/// Steps of the [Security1] session handshake.
///
/// Each value names what the next call to [Security1.securitySession] does.
/// The handshake goes through them in order.
enum SecurityState {
  /// Sends session command 0 with the client's public key.
  request1,

  /// Reads session response 0 (the device's public key and random) and sends
  /// session command 1 with the client verification data.
  response1Request2,

  /// Reads session response 1 and checks the device verification data.
  response2,

  /// The handshake has finished; further calls return `null`.
  finish,
}

/// Steps of the [Security0] session handshake.
///
/// Each value names what the next call to [Security0.securitySession] does.
/// The handshake goes through them in order.
enum Security0State {
  /// Sends the Security 0 session command.
  step0Request,

  /// Checks that the device answered with a Security 0 session response.
  step0Response,

  /// The handshake has finished; further calls return `null`.
  finish,
}

/// A security scheme of the provisioning protocol: it runs the session
/// handshake with the device and protects the data sent afterwards.
///
/// [EspProv] uses it for every request. The package ships [Security1] and
/// [Security0]; implement this class to support another scheme.
abstract class ProvSecurity {
  /// Protects [data] before it is sent to the device and returns the result.
  ///
  /// [Security1] encrypts it with the session key; [Security0] returns it
  /// unchanged.
  Future<Uint8List> encrypt(Uint8List data);

  /// Recovers the plain data from [data], a response received from the
  /// device, and returns it.
  ///
  /// [Security1] decrypts it with the session key; [Security0] returns it
  /// unchanged.
  Future<Uint8List> decrypt(Uint8List data);

  /// Runs one step of the session handshake.
  ///
  /// [EspProv.establishSession] calls it first with an empty `SessionData`
  /// and then with each response that the device sends to the
  /// `prov-session` endpoint, already decoded. It returns the next request
  /// to send, or `null` when the handshake has finished. Throw to reject a
  /// response; [EspProv.establishSession] then returns
  /// [EstablishSessionStatus.keymismatch] or
  /// [EstablishSessionStatus.disconnected].
  ///
  /// Return `null` again when it is called after the handshake has finished,
  /// as [Security1] and [Security0] do, so that calling
  /// [EspProv.establishSession] again does not repeat the handshake.
  Future<SessionData?> securitySession(SessionData responseData);
}
