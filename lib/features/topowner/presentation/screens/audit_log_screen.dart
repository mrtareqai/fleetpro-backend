import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/providers/locale_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final logs = MockData.globalActivities();

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('audit_log_title', locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: SingleChildScrollView(
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
                            case 'create':
                              typeColor = AppColors.success;
                              break;
                            case 'security':
                              typeColor = AppColors.danger;
                              break;
                            case 'update':
                              typeColor = AppColors.purple;
                              break;
                            default:
                              typeColor = AppColors.info;
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
