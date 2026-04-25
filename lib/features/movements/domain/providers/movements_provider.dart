import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class ActivityLogModel {
  final String id;
  final String action;
  final String description;
  final DateTime timestamp;
  final String type;
  final String? userName;
  final String? icon;

  ActivityLogModel({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.type,
    this.userName,
    this.icon,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'],
      action: json['action'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      userName: json['userName'],
      icon: json['icon'],
    );
  }
}

class MovementsNotifier extends StateNotifier<AsyncValue<List<ActivityLogModel>>> {
  final Ref ref;

  MovementsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/logs');
      final List<ActivityLogModel> logs = (response.data as List)
          .map((e) => ActivityLogModel.fromJson(e))
          .toList();
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final movementsProvider = StateNotifierProvider<MovementsNotifier, AsyncValue<List<ActivityLogModel>>>((ref) {
  return MovementsNotifier(ref);
});
