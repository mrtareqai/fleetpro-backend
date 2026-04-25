import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../dashboard/presentation/widgets/stat_card.dart';

class TopOwnerDashboardScreen extends ConsumerWidget {
  const TopOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final totalCompanies = MockData.tenants.length;
    final activeCompanies = MockData.tenants.where((t) => t.isActive).length;
    final inactiveCompanies = totalCompanies - activeCompanies;
    final blockedIps = MockData.blockedIps.where((b) => b.isBlocked).length;
    final totalUsers = MockData.users.where((u) => u.role != 'topowner').length;
    final activities = MockData.globalActivities();
    final isWide = MediaQuery.of(context).size.width > 1100;

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('topowner_dashboard', locale),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Text(
                AppStrings.get('system_overview', locale),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // ─── Stats ───
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: isWide ? (MediaQuery.of(context).size.width - 310) / 4 : 300,
                    child: StatCard(
                      title: AppStrings.get('total_companies', locale),
                      value: '$totalCompanies',
                      icon: Icons.business_rounded,
                      iconColor: AppColors.vehicleIcon,
                      iconBgColor: AppColors.vehicleBg,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (MediaQuery.of(context).size.width - 310) / 4 : 300,
                    child: StatCard(
                      title: AppStrings.get('active_companies', locale),
                      value: '$activeCompanies',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.performanceIcon,
                      iconBgColor: AppColors.performanceBg,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (MediaQuery.of(context).size.width - 310) / 4 : 300,
                    child: StatCard(
                      title: AppStrings.get('inactive_companies', locale),
                      value: '$inactiveCompanies',
                      icon: Icons.cancel_rounded,
                      iconColor: AppColors.ticketIcon,
                      iconBgColor: AppColors.ticketBg,
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (MediaQuery.of(context).size.width - 310) / 4 : 300,
                    child: StatCard(
                      title: AppStrings.get('blocked_ips', locale),
                      value: '$blockedIps',
                      icon: Icons.shield_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: StatCard(
                  title: AppStrings.get('total_users', locale),
                  value: '$totalUsers',
                  icon: Icons.people_rounded,
                  iconColor: AppColors.driverIcon,
                  iconBgColor: AppColors.driverBg,
                ),
              ),
              const SizedBox(height: 20),

              // ─── Companies Chart + Activities ───
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _companyStatusChart(locale, activeCompanies, inactiveCompanies)),
                    const SizedBox(width: 14),
                    Expanded(child: _recentActivities(locale, activities)),
                  ],
                )
              else ...[
                _companyStatusChart(locale, activeCompanies, inactiveCompanies),
                const SizedBox(height: 14),
                _recentActivities(locale, activities),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _companyStatusChart(String locale, int active, int inactive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ar' ? 'حالة الشركات' : 'Company Status',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: active.toDouble(),
                    color: AppColors.chartGreen,
                    title: '$active',
                    radius: 35,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: inactive.toDouble(),
                    color: AppColors.chartRed,
                    title: '$inactive',
                    radius: 35,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivities(String locale, List<ActivityLog> activities) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('audit_logs', locale),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...activities.take(7).map((a) {
            final minutesAgo = DateTime.now().difference(a.timestamp).inMinutes;
            final timeText = minutesAgo < 60
                ? (locale == 'ar' ? 'منذ $minutesAgo دقيقة' : '$minutesAgo min ago')
                : (locale == 'ar' ? 'منذ ${minutesAgo ~/ 60} ساعة' : '${minutesAgo ~/ 60}h ago');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(a.icon ?? '📋', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        Text('${a.userName} • $timeText', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
