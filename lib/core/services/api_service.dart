import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

class ApiService {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  VoidCallback? onUnauthorized;

  String? _cachedToken;

  ApiService(this._secureStorage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 🔐 Token cache (أداء أفضل)
          _cachedToken ??= await _secureStorage.getToken();

          if (_cachedToken != null && _cachedToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }

          debugPrint('🌐 ${options.method} ${options.uri}');
          return handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },

        onError: (DioException e, handler) {
          debugPrint('❌ ${e.response?.statusCode} ${e.message}');

          // 🚨 401 handling آمن
          if (e.response?.statusCode == 401) {
            _cachedToken = null;
            onUnauthorized?.call();
          }

          return handler.next(e);
        },
      ),
    );
  }

  // 🌍 تحديد البيئة
  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }

    if (Platform.isIOS) {
      return 'http://127.0.0.1:3000/api';
    }

    // 🚀 Production
    return 'https://your-production-domain.com/api';
  }

  // ======================
  // HTTP METHODS
  // ======================

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ======================
  // ERROR HANDLER
  // ======================

  String _handleError(DioException error) {
    final response = error.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data;

      if (data['error'] != null) {
        return data['error'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهى وقت الاتصال، حاول مرة أخرى';

      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالسيرفر';

      default:
        return 'خطأ غير متوقع: ${error.message}';
    }
  }
}
