import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Dynamic HMAC Request Signer adhering strictly to:
/// staffRULES.md Tier 3: Dynamic HMAC Request Signing (X-App-Signature).
/// Format: HMAC-SHA256(timestamp + nonce + payload + sessionSecret)
class HmacSigner {
  HmacSigner._();

  /// Calculates dynamic HMAC-SHA256 signature for outgoing API requests.
  static String signRequest({
    required String timestamp,
    required String nonce,
    required dynamic body,
    required String sessionSecret,
  }) {
    // Normalize body into serialized string representation
    final String normalizedBody;
    if (body == null) {
      normalizedBody = '';
    } else if (body is String) {
      normalizedBody = body;
    } else {
      normalizedBody = jsonEncode(body);
    }

    // Message payload: timestamp:nonce:body
    final message = '$timestamp:$nonce:$normalizedBody';
    final keyBytes = utf8.encode(sessionSecret);
    final messageBytes = utf8.encode(message);

    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(messageBytes);
    return digest.toString();
  }
}
