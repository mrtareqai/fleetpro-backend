import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final tenantId = authState.tenant?.id ?? 't1';
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1100;

    final vehicleCount = MockData.vehicleCountForTenant(tenantId);
    final driverCount = MockData.driverCountForTenant(tenantId);
    final activeRes = MockData.activeReservationsForTenant(tenantId);
    final ticketCount = MockData.ticketCountForTenant(tenantId);
    final fleetStatus = MockData.fleetStatusForTenant(tenantId);
    final activities = MockData.activitiesForTenant(tenantId);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('dashboard_overview', locale),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(locale),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Stat Cards Row 1 ───
              _buildStatCardsRow(
                locale: locale,
                vehicleCount: vehicleCount,
                driverCount: driverCount,
                activeRes: activeRes,
                ticketCount: ticketCount,
                isWide: isWide,
              ),
              const SizedBox(height: 14),

              // ─── Stat Cards Row 2 ───
              _buildSecondaryStats(locale: locale, isWide: isWide),
              const SizedBox(height: 20),

              // ─── Charts Row ───
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMonthlyChart(locale),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildFleetStatusChart(locale, fleetStatus),
                    ),
                  ],
                )
              else ...[
                _buildMonthlyChart(locale),
                const SizedBox(height: 14),
                _buildFleetStatusChart(locale, fleetStatus),
              ],
              const SizedBox(height: 14),

              // ─── Bottom Row ───
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildWeeklyChart(locale),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildRecentActivities(locale, activities),
                    ),
                  ],
                )
              else ...[
                _buildWeeklyChart(locale),
                const SizedBox(height: 14),
                _buildRecentActivities(locale, activities),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String locale) {
    final now = DateTime.now();
    final days = locale == 'ar'
        ? ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']
        : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = locale == 'ar'
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
        : ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildStatCardsRow({
    required String locale,
    required int vehicleCount,
    required int driverCount,
    required int activeRes,
    required int ticketCount,
    required bool isWide,
  }) {
    final cards = [
      StatCard(
        title: AppStrings.get('total_vehicles', locale),
        value: '$vehicleCount',
        icon: Icons.directions_bus_rounded,
        iconColor: AppColors.vehicleIcon,
        iconBgColor: AppColors.vehicleBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
      StatCard(
        title: AppStrings.get('total_drivers', locale),
        value: '$driverCount',
        icon: Icons.people_rounded,
        iconColor: AppColors.driverIcon,
        iconBgColor: AppColors.driverBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
      StatCard(
        title: AppStrings.get('active_reservations', locale),
        value: '$activeRes',
        icon: Icons.calendar_month_rounded,
        iconColor: AppColors.reservationIcon,
        iconBgColor: AppColors.reservationBg,
        subtitle: '  1 ${AppStrings.get('upcoming', locale)}',
      ),
      StatCard(
        title: AppStrings.get('total_tickets', locale),
        value: '$ticketCount',
        icon: Icons.confirmation_number_rounded,
        iconColor: AppColors.ticketIcon,
        iconBgColor: AppColors.ticketBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int cols = 4;
        if (width < 650) {
          cols = 1;
        } else if (width < 1100) {
          cols = 2;
        }
        final spacing = 14.0;
        final itemWidth = (width - ((cols - 1) * spacing)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
        );
      },
    );
  }

  Widget _buildSecondaryStats({required String locale, required bool isWide}) {
    final cards = [
      StatCard(
        title: AppStrings.get('performance', locale),
        value: '94%',
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.performanceIcon,
        iconBgColor: AppColors.performanceBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
      StatCard(
        title: AppStrings.get('active_transfers', locale),
        value: '0',
        icon: Icons.location_on_rounded,
        iconColor: AppColors.transferIcon,
        iconBgColor: AppColors.transferBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
      StatCard(
        title: AppStrings.get('supplies', locale),
        value: '0',
        icon: Icons.inventory_2_rounded,
        iconColor: AppColors.supplyIcon,
        iconBgColor: AppColors.supplyBg,
        changeText: '0.0% ${AppStrings.get('change', locale)}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int cols = 3;
        if (width < 650) {
          cols = 1;
        } else if (width < 1100) {
          cols = 2;
        }
        final spacing = 14.0;
        final itemWidth = (width - ((cols - 1) * spacing)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
        );
      },
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
    double? height,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7090B0).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(height: height ?? 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(String locale) {
    final data = MockData.monthlyData();
    final labels =
        locale == 'ar' ? MockData.monthLabelsAr() : MockData.monthLabelsEn();
    return _buildChartCard(
      title: AppStrings.get('monthly_activity', locale),
      subtitle: AppStrings.get('monthly_subtitle', locale),
      chart: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i],
                  color: AppColors.chartBlue,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFleetStatusChart(String locale, Map<String, int> status) {
    final total = status.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return _buildChartCard(
        title: AppStrings.get('fleet_status', locale),
        subtitle: AppStrings.get('fleet_distribution', locale),
        chart: const Center(child: Text('No data')),
      );
    }

    return _buildChartCard(
      title: AppStrings.get('fleet_status', locale),
      subtitle: AppStrings.get('fleet_distribution', locale),
      chart: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: status['active']!.toDouble(),
                    color: AppColors.chartGreen,
                    title: '${status['active']}',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: status['inactive']!.toDouble(),
                    color: AppColors.chartRed,
                    title: '${status['inactive']}',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: status['expired']!.toDouble(),
                    color: AppColors.chartYellow,
                    title: '${status['expired']}',
                    radius: 30,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendItem(AppColors.chartGreen, '${status['active']}',
                  AppStrings.get('active', locale)),
              const SizedBox(height: 8),
              _legendItem(AppColors.chartRed, '${status['inactive']}',
                  AppStrings.get('inactive', locale)),
              const SizedBox(height: 8),
              _legendItem(AppColors.chartYellow, '${status['expired']}',
                  AppStrings.get('expired', locale)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String value, String label) {
    return Row(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(String locale) {
    final data = MockData.weeklyData();
    final labels =
        locale == 'ar' ? MockData.weekDaysAr() : MockData.weekDaysEn();
    return _buildChartCard(
      title: AppStrings.get('weekly_activity', locale),
      subtitle: AppStrings.get('weekly_subtitle', locale),
      chart: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i],
                  color: AppColors.chartBlue,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(String locale, List<ActivityLog> activities) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7090B0).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('recent_activities', locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppStrings.get('recent_subtitle', locale),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  AppStrings.get('view_all', locale),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.take(5).map((a) => _activityItem(a, locale)),
        ],
      ),
    );
  }

  Widget _activityItem(ActivityLog log, String locale) {
    Color typeColor;
    String typeLabel;
    switch (log.type) {
      case 'create':
        typeColor = AppColors.success;
        typeLabel = locale == 'ar' ? 'تم إنشاء' : 'Created';
        break;
      case 'update':
        typeColor = AppColors.purple;
        typeLabel = locale == 'ar' ? 'تم تحديث' : 'Updated';
        break;
      case 'delete':
        typeColor = AppColors.danger;
        typeLabel = locale == 'ar' ? 'تم حذف' : 'Deleted';
        break;
      default:
        typeColor = AppColors.info;
        typeLabel = locale == 'ar' ? 'نظام' : 'System';
    }

    final minutesAgo = DateTime.now().difference(log.timestamp).inMinutes;
    String timeText;
    if (minutesAgo < 1) {
      timeText = AppStrings.get('just_now', locale);
    } else if (minutesAgo < 60) {
      timeText = locale == 'ar'
          ? 'منذ $minutesAgo دقيقة'
          : '$minutesAgo min ago';
    } else {
      final hours = minutesAgo ~/ 60;
      timeText = locale == 'ar'
          ? 'منذ $hours ساعة'
          : '$hours hours ago';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(log.icon ?? '📋', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      '${log.userName ?? ''} • $timeText',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                color: typeColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
