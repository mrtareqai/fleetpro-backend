import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppUserModel {
  final String id;
  final String username;
  final String role;
  final String displayName;
  final bool isActive;
  final bool mustChangePassword;
  final String? tenantId;

  AppUserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.displayName,
    required this.isActive,
    required this.mustChangePassword,
    this.tenantId,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      displayName: json['displayName'],
      isActive: json['isActive'],
      mustChangePassword: json['mustChangePassword'],
      tenantId: json['tenantId'],
    );
  }
}

class UsersNotifier extends StateNotifier<AsyncValue<List<AppUserModel>>> {
  final Ref ref;

  UsersNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/users');
      final List<AppUserModel> users = (response.data as List)
          .map((e) => AppUserModel.fromJson(e))
          .toList();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addUser(Map<String, dynamic> data) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/users', data: data);
    await fetchUsers();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/users/$id', data: data);
    await fetchUsers();
  }

  Future<void> toggleStatus(String id, bool newStatus) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/users/$id', data: {'isActive': newStatus});
    await fetchUsers();
  }

  Future<void> deleteUser(String id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/users/$id');
    await fetchUsers();
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<AppUserModel>>>((ref) {
  return UsersNotifier(ref);
});
