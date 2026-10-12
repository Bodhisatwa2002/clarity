import 'dart:math';

/// Client-side ids, so new places and visits can show up before the server
/// replies (the database accepts the id the app sends).
abstract final class Ids {
  static final Random _random = Random.secure();

  /// A random RFC 4122 version-4 UUID.
  static String uuid() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
