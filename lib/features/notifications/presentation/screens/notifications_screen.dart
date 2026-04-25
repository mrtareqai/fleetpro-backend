import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeBg = AppColors.bgLight;
    
    final notifsState = ref.watch(notificationsProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: themeBg,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('notifications', locale),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: notifsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('خطأ في تحميل الإشعارات: $err')),
                    data: (notifs) {
                      if (notifs.isEmpty) {
                        return Center(child: Text(AppStrings.get('no_data', locale)));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifs.length,
                        separatorBuilder: (ctx, idx) => const Divider(),
                        itemBuilder: (ctx, idx) {
                          final notif = notifs[idx];
                          final minutesAgo = DateTime.now().difference(notif.createdAt).inMinutes;
                          final timeText = minutesAgo < 60
                              ? (locale == 'ar' ? 'منذ $minutesAgo دقيقة' : '$minutesAgo min ago')
                              : (locale == 'ar' ? 'منذ ${minutesAgo ~/ 60} ساعة' : '${minutesAgo ~/ 60}h ago');

                          IconData icon;
                          Color color;
                          if (notif.type == 'booking') {
                            icon = Icons.book_online_rounded;
                            color = AppColors.primary;
                          } else if (notif.type == 'alert') {
                            icon = Icons.warning_rounded;
                            color = AppColors.warning;
                          } else {
                            icon = Icons.info_outline_rounded;
                            color = AppColors.info;
                          }

                          return ListTile(
                            onTap: notif.isRead ? null : () {
                              ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                            },
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.1),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            title: Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notif.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(timeText, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                              ],
                            ),
                            trailing: notif.isRead
                                ? null
                                : Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          );
                        },
                      );
                    }
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
