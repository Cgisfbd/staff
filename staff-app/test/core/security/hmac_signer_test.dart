import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/security/hmac_signer.dart';

void main() {
  group('HmacSigner', () {
    const timestamp = '1725984000000';
    const nonce = 'test-nonce-uuid-1234';
    const sessionSecret = 'super_secret_session_key_faang_standard';
    final payload = {'student_id': 101, 'status': 'PRESENT'};

    test('should produce consistent deterministic signature for identical inputs', () {
      final sig1 = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: payload,
        sessionSecret: sessionSecret,
      );

      final sig2 = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: payload,
        sessionSecret: sessionSecret,
      );

      expect(sig1, isNotEmpty);
      expect(sig1, equals(sig2));
    });

    test('should detect payload tampering (changing 1 char changes signature)', () {
      final validSig = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: payload,
        sessionSecret: sessionSecret,
      );

      final tamperedPayload = {'student_id': 101, 'status': 'ABSENT'};
      final tamperedSig = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: tamperedPayload,
        sessionSecret: sessionSecret,
      );

      expect(validSig, isNot(equals(tamperedSig)));
    });

    test('should handle null and string bodies without throwing', () {
      final sigNull = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: null,
        sessionSecret: sessionSecret,
      );

      final sigStr = HmacSigner.signRequest(
        timestamp: timestamp,
        nonce: nonce,
        body: 'raw-string-body',
        sessionSecret: sessionSecret,
      );

      expect(sigNull, isNotEmpty);
      expect(sigStr, isNotEmpty);
    });
  });
}
