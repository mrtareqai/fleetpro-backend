import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/models/route_model.dart';
import '../../domain/providers/routes_provider.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final tenantId = ref.watch(authProvider).tenant?.id ?? 't1';
    final isMobile = MediaQuery.of(context).size.width < 800;

    // Agent logic simulation
    final currentUser = ref.watch(authProvider).user;
    final isAgent = currentUser?.role == 'operator'; // Using operator as proxy for agent for now
    int? currentAgentId;
    if (isAgent) {
      final agentData = MockData.agents.where((a) => a.tenantId == tenantId).firstOrNull;
      currentAgentId = agentData?.id;
    }

    final routesState = ref.watch(routesProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('routes_management', locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildToolbar(locale),
              const SizedBox(height: 12),
              _buildActions(locale),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: routesState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
                          const SizedBox(height: 16),
                          Text(err.toString(), style: const TextStyle(color: AppColors.danger)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(routesProvider.notifier).fetchData(),
                            child: const Text('إعادة المحاولة'),
                          )
                        ],
                      ),
                    ),
                    data: (dataItems) {
                      var items = dataItems;
                      
                      if (isAgent && currentAgentId != null) {
                        items = items.where((r) => r.agentId == currentAgentId).toList();
                      }

                      if (_searchQuery.isNotEmpty) {
                        items = items.where((r) =>
                            r.originCity.contains(_searchQuery) ||
                            r.destinationCity.contains(_searchQuery)).toList();
                      }

                      if (items.isEmpty) {
                        return Center(child: Text(AppStrings.get('no_data', locale)));
                      }

                      return isMobile
                          ? _buildMobileList(items, locale)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
                                  columns: [
                                    DataColumn(label: Text(AppStrings.get('id', locale))),
                                    DataColumn(label: Text(AppStrings.get('origin_city', locale))),
                                    DataColumn(label: Text(AppStrings.get('destination_city', locale))),
                                    DataColumn(label: Text(AppStrings.get('branch', locale))),
                                    DataColumn(label: Text(AppStrings.get('agent', locale))),
                                    DataColumn(label: Text(AppStrings.get('stops_count', locale))),
                                    DataColumn(label: Text(AppStrings.get('estimated_duration', locale))),
                                    DataColumn(label: Text(AppStrings.get('base_price', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                  ],
                                  rows: items.map((r) {
                                    final branchName = MockData.branches.where((b) => b.id == r.branchId).firstOrNull?.name ?? '-';
                                    final agentName = MockData.agents.where((a) => a.id == r.agentId).firstOrNull?.name ?? '-';

                                    return DataRow(cells: [
                                      DataCell(Text('${r.id}')),
                                      DataCell(Text(r.originCity)),
                                      DataCell(Text(r.destinationCity)),
                                      DataCell(Text(branchName)),
                                      DataCell(Text(agentName)),
                                      DataCell(Text('${r.stopsCount}')),
                                      DataCell(Text('${r.estimatedDuration}')),
                                      DataCell(Text('${r.basePrice}')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: r.status == 'active' ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(AppStrings.get(r.status, locale),
                                              style: TextStyle(color: r.status == 'active' ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(String locale) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: AppStrings.get('search', locale),
              prefixIcon: const Icon(Icons.search, size: 20),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
          onPressed: () {
            ref.read(routesProvider.notifier).fetchData();
          },
        ),
      ],
    );
  }

  Widget _buildActions(String locale) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppButton(
          label: AppStrings.get('add', locale),
          icon: Icons.add_rounded,
          variant: AppButtonVariant.success,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMobileList(List<RouteModel> items, String locale) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = items[index];
        final branchName = MockData.branches.where((b) => b.id == r.branchId).firstOrNull?.name ?? '-';
        final agentName = MockData.agents.where((a) => a.id == r.agentId).firstOrNull?.name ?? '-';
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.originCity} ➔ ${r.destinationCity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              if (r.branchId != null)
                Text('${AppStrings.get('branch', locale)}: $branchName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              if (r.agentId != null)
                Text('${AppStrings.get('agent', locale)}: $agentName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('base_price', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('${r.basePrice}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
