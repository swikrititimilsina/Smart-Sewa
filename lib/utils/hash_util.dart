import 'dart:convert';
import 'dart:math';

/// Simple hash/utility functions for the app.
class HashUtil {
  /// Generates a simple random ID string.
  static String generateId({int length = 8}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Simple base64 encode for demo purposes.
  static String encode(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Simple base64 decode for demo purposes.
  static String decode(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }
}
