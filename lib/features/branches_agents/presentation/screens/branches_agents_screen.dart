import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/branches_agents_provider.dart';

class BranchesAgentsScreen extends ConsumerStatefulWidget {
  const BranchesAgentsScreen({super.key});

  @override
  ConsumerState<BranchesAgentsScreen> createState() => _BranchesAgentsScreenState();
}

class _BranchesAgentsScreenState extends ConsumerState<BranchesAgentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('branches_agents', locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: AppStrings.get('branches_management', locale)),
                    Tab(text: AppStrings.get('agents_management', locale)),
                  ],
                ),
              ),
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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBranchesView(locale, isMobile),
                      _buildAgentsView(locale, isMobile),
                    ],
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
          onPressed: () {}, // To be implemented with permission checks
        ),
      ],
    );
  }

  Widget _buildBranchesView(String locale, bool isMobile) {
    final branchesState = ref.watch(branchesProvider);
    
    return branchesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (branches) {
        var items = branches;
        if (_searchQuery.isNotEmpty) {
          items = items.where((b) => b.name.contains(_searchQuery) || b.location.contains(_searchQuery)).toList();
        }

        if (items.isEmpty) return Center(child: Text(AppStrings.get('no_data', locale)));

        if (isMobile) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = items[index];
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
                    Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(b.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
              columns: [
                DataColumn(label: Text(AppStrings.get('id', locale))),
                DataColumn(label: Text(AppStrings.get('company_name', locale))), // Using branch instead
                DataColumn(label: Text(AppStrings.get('location', locale))),
                DataColumn(label: Text(AppStrings.get('status', locale))),
              ],
              rows: items.map((b) {
                return DataRow(cells: [
                  DataCell(Text('${b.id}')),
                  DataCell(Text(b.name)),
                  DataCell(Text(b.location)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: b.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(AppStrings.get(b.isActive ? 'active' : 'inactive', locale),
                          style: TextStyle(color: b.isActive ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      }
    );
  }

  Widget _buildAgentsView(String locale, bool isMobile) {
    final agentsState = ref.watch(agentsProvider);
    final branchesState = ref.watch(branchesProvider);
    
    return agentsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (agents) {
        var items = agents;
        if (_searchQuery.isNotEmpty) {
          items = items.where((a) => a.name.contains(_searchQuery) || a.phone.contains(_searchQuery)).toList();
        }

        if (items.isEmpty) return Center(child: Text(AppStrings.get('no_data', locale)));

        if (isMobile) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = items[index];
              final branchName = branchesState.maybeWhen(
                data: (branches) => branches.where((b) => b.id == a.branchId).firstOrNull?.name ?? '-',
                orElse: () => '-',
              );
              
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
                    Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${AppStrings.get('phone', locale)}: ${a.phone}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('${AppStrings.get('branch', locale)}: $branchName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
              columns: [
                DataColumn(label: Text(AppStrings.get('id', locale))),
                DataColumn(label: Text(AppStrings.get('agent', locale))),
                DataColumn(label: Text(AppStrings.get('phone', locale))),
                DataColumn(label: Text(AppStrings.get('branch', locale))),
                DataColumn(label: Text(AppStrings.get('commission', locale))),
                DataColumn(label: Text(AppStrings.get('status', locale))),
              ],
              rows: items.map((a) {
                final branchName = branchesState.maybeWhen(
                  data: (branches) => branches.where((b) => b.id == a.branchId).firstOrNull?.name ?? '-',
                  orElse: () => '-',
                );
                
                return DataRow(cells: [
                  DataCell(Text('${a.id}')),
                  DataCell(Text(a.name)),
                  DataCell(Text(a.phone)),
                  DataCell(Text(branchName)),
                  DataCell(Text('${a.commission}%')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: a.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(AppStrings.get(a.isActive ? 'active' : 'inactive', locale),
                          style: TextStyle(color: a.isActive ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      }
    );
  }
}
