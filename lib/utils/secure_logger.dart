import 'package:flutter/foundation.dart';

/// Minimal logger that prevents leaking exception details in release builds.
///
/// - Uses [debugPrint] only when running in debug.
/// - In release, no-op.
class SecureLogger {
  static void d(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }

  static void w(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }
}

