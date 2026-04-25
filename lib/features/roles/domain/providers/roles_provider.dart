import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppRoleModel {
  final String id;
  final String name;
  final String nameAr;
  final List<String> permissions;

  AppRoleModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.permissions,
  });

  factory AppRoleModel.fromJson(Map<String, dynamic> json) {
    return AppRoleModel(
      id: json['id'],
      name: json['name'],
      nameAr: json['nameAr'] ?? json['name'],
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameAr': nameAr,
      'permissions': permissions,
    };
  }
}

class RolesNotifier extends StateNotifier<AsyncValue<List<AppRoleModel>>> {
  final Ref ref;

  RolesNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/roles');
      final List<AppRoleModel> roles = (response.data as List)
          .map((e) => AppRoleModel.fromJson(e))
          .toList();
      state = AsyncValue.data(roles);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRole(AppRoleModel role) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/roles', data: role.toJson());
    await fetchRoles();
  }

  Future<void> updateRole(String id, AppRoleModel role) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/roles/$id', data: role.toJson());
    await fetchRoles();
  }

  Future<void> deleteRole(String id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/roles/$id');
    await fetchRoles();
  }
}

final rolesProvider = StateNotifierProvider<RolesNotifier, AsyncValue<List<AppRoleModel>>>((ref) {
  return RolesNotifier(ref);
});
