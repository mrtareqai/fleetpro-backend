import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class AppBranch {
  final int id;
  final String name;
  final String location;
  final bool isActive;

  AppBranch({
    required this.id,
    required this.name,
    required this.location,
    required this.isActive,
  });

  factory AppBranch.fromJson(Map<String, dynamic> json) {
    return AppBranch(
      id: json['id'],
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'isActive': isActive,
    };
  }
}

class AppAgent {
  final int id;
  final String name;
  final String phone;
  final int? branchId;
  final double commission;
  final bool isActive;

  AppAgent({
    required this.id,
    required this.name,
    required this.phone,
    this.branchId,
    required this.commission,
    required this.isActive,
  });

  factory AppAgent.fromJson(Map<String, dynamic> json) {
    return AppAgent(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      branchId: json['branchId'],
      commission: (json['commission'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'branchId': branchId,
      'commission': commission,
      'isActive': isActive,
    };
  }
}

class BranchesNotifier extends StateNotifier<AsyncValue<List<AppBranch>>> {
  final Ref ref;

  BranchesNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/branches');
      final List<AppBranch> branches = (response.data as List)
          .map((e) => AppBranch.fromJson(e))
          .toList();
      state = AsyncValue.data(branches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBranch(AppBranch branch) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/branches', data: branch.toJson());
    await fetchBranches();
  }

  Future<void> updateBranch(int id, AppBranch branch) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/branches/$id', data: branch.toJson());
    await fetchBranches();
  }

  Future<void> deleteBranch(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/branches/$id');
    await fetchBranches();
  }
}

class AgentsNotifier extends StateNotifier<AsyncValue<List<AppAgent>>> {
  final Ref ref;

  AgentsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/agents');
      final List<AppAgent> agents = (response.data as List)
          .map((e) => AppAgent.fromJson(e))
          .toList();
      state = AsyncValue.data(agents);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAgent(AppAgent agent) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.post('/agents', data: agent.toJson());
    await fetchAgents();
  }

  Future<void> updateAgent(int id, AppAgent agent) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.put('/agents/$id', data: agent.toJson());
    await fetchAgents();
  }

  Future<void> deleteAgent(int id) async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.delete('/agents/$id');
    await fetchAgents();
  }
}

final branchesProvider = StateNotifierProvider<BranchesNotifier, AsyncValue<List<AppBranch>>>((ref) {
  return BranchesNotifier(ref);
});

final agentsProvider = StateNotifierProvider<AgentsNotifier, AsyncValue<List<AppAgent>>>((ref) {
  return AgentsNotifier(ref);
});
