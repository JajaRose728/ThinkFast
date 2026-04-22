import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  final _storage = const FlutterSecureStorage();

  // Encrypt and save sensitive data (e.g., Auth Tokens or User PIN)
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read encrypted data
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }
}