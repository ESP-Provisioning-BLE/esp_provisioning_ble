import 'package:flutter/foundation.dart';

import 'protos/generated/sec0.pb.dart';
import 'protos/generated/session.pb.dart';
import 'security.dart';

class Security0 implements ProvSecurity {
  final bool verbose;
  Security0State sessionState;

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

  @override
  Future<Uint8List> encrypt(Uint8List data) async {
    return data;
  }

  @override
  Future<Uint8List> decrypt(Uint8List data) async {
    return data;
  }

  @override
  Future<SessionData?> securitySession(SessionData? responseData) async {
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

  void _processStep0Response(SessionData? responseData) {
    if (responseData == null) {
      throw Exception('No response from device');
    }
    if (responseData.secVer != SecSchemeVersion.SecScheme0) {
      throw Exception('Security version mismatch');
    }
  }
}
