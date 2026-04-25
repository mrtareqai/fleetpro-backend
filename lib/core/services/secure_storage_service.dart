import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  /// حفظ التوكن
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// قراءة التوكن
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// مسح التوكن عند تسجيل الخروج
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// مسح كل البيانات
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
