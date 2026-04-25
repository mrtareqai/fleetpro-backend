import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_service_provider.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
      type: json['type'],
    );
  }
}

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/notifications');
      final List<NotificationModel> notifications = (response.data as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('/notifications/$id/read', data: {});

      if (state.hasValue) {
        final current = state.value!;
        final index = current.indexWhere((element) => element.id == id);
        if (index != -1) {
          final updatedNotif = NotificationModel(
            id: current[index].id,
            title: current[index].title,
            message: current[index].message,
            createdAt: current[index].createdAt,
            isRead: true,
            type: current[index].type,
          );
          current[index] = updatedNotif;
          state = AsyncValue.data([...current]);
        }
      }
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error marking notification as read: $e');
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      return NotificationsNotifier(ref);
    });
