import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/movements_provider.dart';

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    final logsState = ref.watch(movementsProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('movement', locale),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.read(movementsProvider.notifier).fetchLogs(),
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
                  child: logsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('خطأ في تحميل البيانات: $err')),
                    data: (logs) {
                      if (logs.isEmpty) {
                        return Center(child: Text(AppStrings.get('no_data', locale)));
                      }
                      
                      if (isMobile) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: logs.length,
                          separatorBuilder: (ctx, idx) => const Divider(),
                          itemBuilder: (ctx, idx) {
                            final log = logs[idx];
                            final minutesAgo = DateTime.now().difference(log.timestamp).inMinutes;
                            final timeText = minutesAgo < 60
                                ? (locale == 'ar' ? 'منذ $minutesAgo دقيقة' : '$minutesAgo min ago')
                                : (locale == 'ar' ? 'منذ ${minutesAgo ~/ 60} ساعة' : '${minutesAgo ~/ 60}h ago');
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(log.icon ?? '📋', style: const TextStyle(fontSize: 18)),
                              ),
                              title: Text(log.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              subtitle: Text('${log.userName ?? ''} • $timeText', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                              trailing: Text(AppStrings.get(log.type, locale), style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                            );
                          },
                        );
                      }
                      
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.bgLight),
                            columns: [
                              DataColumn(label: Text(AppStrings.get('id', locale))),
                              DataColumn(label: Text(AppStrings.get('action', locale))),
                              DataColumn(label: Text(AppStrings.get('details', locale))),
                              DataColumn(label: Text(AppStrings.get('user', locale))),
                              DataColumn(label: Text(AppStrings.get('timestamp', locale))),
                            ],
                            rows: logs.asMap().entries.map((entry) {
                              final log = entry.value;
                              final minutesAgo = DateTime.now().difference(log.timestamp).inMinutes;
                              final timeText = minutesAgo < 60
                                  ? (locale == 'ar' ? 'منذ $minutesAgo دقيقة' : '$minutesAgo min ago')
                                  : (locale == 'ar' ? 'منذ ${minutesAgo ~/ 60} ساعة' : '${minutesAgo ~/ 60}h ago');
                              Color typeColor;
                              switch (log.type) {
                                case 'create': typeColor = AppColors.success; break;
                                case 'security': typeColor = AppColors.danger; break;
                                case 'update': typeColor = AppColors.purple; break;
                                default: typeColor = AppColors.info;
                              }
                              return DataRow(cells: [
                                DataCell(Text('${entry.key + 1}')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      log.action,
                                      style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                DataCell(SizedBox(
                                  width: 250,
                                  child: Text(log.description, overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Text(log.userName ?? '-')),
                                DataCell(Text(timeText)),
                              ]);
                            }).toList(),
                          ),
                        ),
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
