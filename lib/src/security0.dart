import 'package:flutter/foundation.dart';

import 'protos/generated/sec0.pb.dart';
import 'protos/generated/session.pb.dart';
import 'security.dart';

/// Security 0 of the provisioning protocol: no encryption and no proof of
/// possession.
///
/// Use it with devices whose firmware is built with `WIFI_PROV_SECURITY_0`
/// (`protocomm_security0`). Everything, including the Wi-Fi password, travels
/// in the clear over BLE.
///
/// The handshake has a single round: [securitySession] sends a Security 0
/// session command and checks that the device answers with a Security 0
/// session response. [encrypt] and [decrypt] return the data unchanged.
///
/// An instance holds the state of one handshake and does not reset after a
/// failed one: create a new instance to try again.
///
/// ```dart
/// final prov = EspProv(transport: myTransport, security: Security0());
/// ```
class Security0 implements ProvSecurity {
  /// Whether to print each handshake step for debugging. It only prints in
  /// debug builds.
  final bool verbose;

  /// The next step of the handshake. It starts at
  /// [Security0State.step0Request] unless another state is passed to the
  /// constructor.
  Security0State sessionState;

  /// Creates a Security 0 scheme that starts its handshake at
  /// [sessionState].
  Security0({
    this.verbose = false,
    this.sessionState = Security0State.step0Request,
  });

  void _verbose(dynamic data) {
    if (verbose) {
      if (kDebugMode) {
        print('+++ $data +++');
      }
    }
  }

  /// Returns [data] unchanged: Security 0 does not encrypt.
  @override
  Future<Uint8List> encrypt(Uint8List data) async {
    return data;
  }

  /// Returns [data] unchanged: Security 0 does not encrypt.
  @override
  Future<Uint8List> decrypt(Uint8List data) async {
    return data;
  }

  /// Runs the next step of the Security 0 handshake, as described in
  /// [ProvSecurity.securitySession].
  ///
  /// In [Security0State.step0Request] it returns the session command and
  /// moves to [Security0State.step0Response]. In
  /// [Security0State.step0Response] it checks [responseData] and returns
  /// `null`, moving to [Security0State.finish]; it throws if the response
  /// does not use Security 0 or has no Security 0 session response, and then
  /// stays in [Security0State.step0Response]. In [Security0State.finish] it
  /// returns `null`.
  @override
  Future<SessionData?> securitySession(SessionData responseData) async {
    if (sessionState == Security0State.step0Request) {
      sessionState = Security0State.step0Response;
      return _getStep0Request();
    }
    if (sessionState == Security0State.step0Response) {
      _processStep0Response(responseData);
      sessionState = Security0State.finish;
      return null;
    }
    if (sessionState == Security0State.finish) {
      return null;
    }
    throw Exception('Unexpected state');
  }

  SessionData _getStep0Request() {
    _verbose('step0Request');
    final setupRequest = SessionData();
    setupRequest.secVer = SecSchemeVersion.SecScheme0;
    final sc0 = S0SessionCmd();
    final s0p = Sec0Payload();
    s0p.sc = sc0;
    setupRequest.sec0 = s0p;
    return setupRequest;
  }

  void _processStep0Response(SessionData responseData) {
    if (responseData.secVer != SecSchemeVersion.SecScheme0) {
      throw Exception('Security version mismatch');
    }
    // secVer defaults to SecScheme0, so an empty SessionData would pass the
    // check above. Require the Security0 session response payload as well.
    if (!responseData.hasSec0() || !responseData.sec0.hasSr()) {
      throw Exception('Missing Security0 session response');
    }
  }
}
