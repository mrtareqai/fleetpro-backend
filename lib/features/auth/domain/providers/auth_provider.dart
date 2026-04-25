import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/mock_data.dart'; // سنتركها حالياً لموديلات الـ AppUser إذا كانت تُستخدم (أو يمكننا إنشاء Models لاحقاً)
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/api_service_provider.dart';
import '../../../../core/services/secure_storage_service.dart';

// ─── Auth State ───

enum AuthStatus { unauthenticated, authenticated, forceChangePassword, initial }

class AuthState {
  final AuthStatus status;
  final AppUser? user; // نستخدم نفس الكلاس الحالي من mock_data مؤقتاً لتوافق الواجهات
  final Tenant? tenant;
  final String? errorMessage;
  final int? remainingAttempts;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.tenant,
    this.errorMessage,
    this.remainingAttempts,
    this.isLoading = false,
  });

  bool get isTopOwner => user?.role == 'topowner';
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    Tenant? tenant,
    String? errorMessage,
    int? remainingAttempts,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      tenant: tenant ?? this.tenant,
      errorMessage: errorMessage,
      remainingAttempts: remainingAttempts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Auth Notifier ───

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._apiService, this._secureStorage) : super(const AuthState()) {
    _apiService.onUnauthorized = () {
      logout();
    };
    checkAuthStatus();
  }

  /// التحقق من وجود التوكن مسبقاً (تسجيل الدخول التلقائي)
  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      // هنا يمكن إضافة طلب للـ API للتحقق من صلاحية التوكن إذا لزم الأمر
      // مؤقتاً نعتبر التوكن صالحاً وننتظر الـ requests المستقبلية لترد بـ 401 إن انتهى
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// محاولة تسجيل الدخول عبر הـ API
  Future<void> login({
    required String username,
    required String password,
    String? serverId, // سيتم تجاهله حالياً لأن הـ Backend الجديد لا يعتمد عليه، ولكن نتركه لتوافق הـ UI
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      final token = data['token'];
      final userData = data['user'];

      // حفظ التوكن
      await _secureStorage.saveToken(token);

      // بناء المستخدم لتوافق الـ UI
      final appUser = AppUser(
        id: userData['id'],
        tenantId: userData['tenantId'],
        username: userData['username'],
        password: '', // لا نحتفظ بالباسورد
        role: userData['role'],
        mustChangePassword: userData['mustChangePassword'] ?? false,
        isActive: true,
        displayName: userData['displayName'] ?? userData['username'],
      );

      // بناء بيانات الشركة
      final tenantData = userData['tenantId'] != null
          ? Tenant(
              id: userData['tenantId'],
              serverId: '',
              name: userData['companyName'] ?? '',
              ownerName: '',
              phone: '',
              email: '',
            )
          : null;

      // تحديث الحالة
      state = AuthState(
        status: appUser.mustChangePassword
            ? AuthStatus.forceChangePassword
            : AuthStatus.authenticated,
        user: appUser,
        tenant: tenantData,
      );
    } catch (e) {
      // e هو عبارة عن String راجع من _handleError في ApiService
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _secureStorage.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, remainingAttempts: null);
  }

  /// تغيير كلمة المرور
  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _apiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      // بعد التغيير بنجاح نعتبره authenticated
      state = state.copyWith(status: AuthStatus.authenticated);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> validateServerId(String serverId) async {
    if (serverId.trim().isEmpty) return null;
    try {
      final response = await _apiService.get('/auth/tenant/${serverId.trim()}');
      if (response.data != null && response.data['name'] != null) {
        return response.data['name'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ─── Provider ───

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(apiService, secureStorage);
});
