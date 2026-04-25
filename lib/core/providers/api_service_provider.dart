import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

/// Provider لتوفير الـ ApiService لبقية أجزاء التطبيق
final apiServiceProvider = Provider<ApiService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiService(secureStorage);
});
