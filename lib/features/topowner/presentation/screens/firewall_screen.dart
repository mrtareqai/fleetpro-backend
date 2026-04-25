import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';

class FirewallScreen extends ConsumerStatefulWidget {
  const FirewallScreen({super.key});

  @override
  ConsumerState<FirewallScreen> createState() => _FirewallScreenState();
}

class _FirewallScreenState extends ConsumerState<FirewallScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('firewall_management', locale),
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
                          DataColumn(label: Text(AppStrings.get('ip_address', locale))),
                          DataColumn(label: Text(AppStrings.get('failed_attempts', locale))),
                          DataColumn(label: Text(AppStrings.get('status', locale))),
                          DataColumn(label: Text(AppStrings.get('reason', locale))),
                          DataColumn(label: Text(AppStrings.get('blocked_until', locale))),
                          DataColumn(label: Text(AppStrings.get('actions', locale))),
                        ],
                        rows: MockData.blockedIps.map((ip) {
                          return DataRow(cells: [
                            DataCell(Text(ip.ipAddress, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ip.failedAttempts >= 8
                                      ? AppColors.dangerLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${ip.failedAttempts}',
                                  style: TextStyle(
                                    color: ip.failedAttempts >= 8 ? AppColors.danger : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (ip.isBlocked ? AppColors.danger : AppColors.success).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      ip.isBlocked ? Icons.block_rounded : Icons.check_circle_rounded,
                                      size: 14,
                                      color: ip.isBlocked ? AppColors.danger : AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.get(ip.isBlocked ? 'blocked' : 'not_blocked', locale),
                                      style: TextStyle(
                                        color: ip.isBlocked ? AppColors.danger : AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(ip.reason ?? '-')),
                            DataCell(Text(ip.blockedUntil != null
                                ? '${ip.blockedUntil!.year}-${ip.blockedUntil!.month.toString().padLeft(2, '0')}-${ip.blockedUntil!.day.toString().padLeft(2, '0')} ${ip.blockedUntil!.hour.toString().padLeft(2, '0')}:${ip.blockedUntil!.minute.toString().padLeft(2, '0')}'
                                : '-')),
                            DataCell(
                              ip.isBlocked
                                  ? AppButton(
                                      label: AppStrings.get('unblock', locale),
                                      icon: Icons.lock_open_rounded,
                                      variant: AppButtonVariant.success,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(AppStrings.get('unblock', locale)),
                                            content: Text(AppStrings.get('unblock_confirm', locale)),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel', locale))),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                                onPressed: () {
                                                  setState(() {
                                                    ip.isBlocked = false;
                                                    ip.failedAttempts = 0;
                                                  });
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text(AppStrings.get('confirm', locale)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : const Text('-'),
                            ),
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
