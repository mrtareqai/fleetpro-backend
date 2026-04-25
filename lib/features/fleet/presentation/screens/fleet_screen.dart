import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/fleet_provider.dart';

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    final fleetState = ref.watch(fleetProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('fleet_management', locale),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              // ─── Toolbar ───
              _buildToolbar(locale),
              const SizedBox(height: 12),
              // ─── Action Buttons ───
              _buildActions(locale),
              const SizedBox(height: 12),
              // ─── Table ───
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: fleetState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, st) => Center(child: Text('Error: $err')),
                    data: (vehicles) {
                      var items = vehicles;
                      if (_statusFilter != 'all') {
                        items = items.where((v) => v.status == _statusFilter).toList();
                      }
                      if (_searchQuery.isNotEmpty) {
                        items = items
                            .where((v) =>
                                v.model.contains(_searchQuery) ||
                                v.plateNumber.contains(_searchQuery))
                            .toList();
                      }

                      if (items.isEmpty) {
                        return Center(child: Text(AppStrings.get('no_data', locale)));
                      }

                      return isMobile
                          ? _buildMobileList(items, locale, dateFormat)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
                                  columns: [
                                    DataColumn(label: Text(AppStrings.get('number', locale))),
                                    DataColumn(label: Text(AppStrings.get('model', locale))),
                                    DataColumn(label: Text(AppStrings.get('manufacture_date', locale))),
                                    DataColumn(label: Text(AppStrings.get('plate_number', locale))),
                                    DataColumn(label: Text(AppStrings.get('base_number', locale))),
                                    DataColumn(label: Text(AppStrings.get('card_number', locale))),
                                    DataColumn(label: Text(AppStrings.get('issue_date', locale))),
                                    DataColumn(label: Text(AppStrings.get('expiry_date', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                  ],
                                  rows: items.map((v) {
                                    return DataRow(cells: [
                                      DataCell(Text('${v.id}')),
                                      DataCell(Text(v.model)),
                                      DataCell(Text(dateFormat.format(v.manufactureDate))),
                                      DataCell(Text(v.plateNumber)),
                                      DataCell(Text(v.baseNumber)),
                                      DataCell(Text(v.cardNumber)),
                                      DataCell(Text(dateFormat.format(v.issueDate))),
                                      DataCell(Text(dateFormat.format(v.expiryDate))),
                                      DataCell(_statusBadge(v.status, locale)),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildFooter(locale),
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
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              items: [
                DropdownMenuItem(
                    value: 'all',
                    child: Text(AppStrings.get('all', locale))),
                DropdownMenuItem(
                    value: 'active',
                    child: Text(AppStrings.get('active', locale))),
                DropdownMenuItem(
                    value: 'inactive',
                    child: Text(AppStrings.get('inactive', locale))),
                DropdownMenuItem(
                    value: 'expired',
                    child: Text(AppStrings.get('expired', locale))),
              ],
              onChanged: (val) => setState(() => _statusFilter = val ?? 'all'),
            ),
          ),
        ),
        AppButton(
          label: AppStrings.get('export_csv', locale),
          icon: Icons.download_rounded,
          variant: AppButtonVariant.outline,
          onPressed: () {},
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
          label: AppStrings.get('clear', locale),
          icon: Icons.refresh_rounded,
          variant: AppButtonVariant.info,
          onPressed: () => setState(() {
            _searchQuery = '';
            _statusFilter = 'all';
          }),
        ),
        AppButton(
          label: AppStrings.get('add', locale),
          icon: Icons.add_rounded,
          variant: AppButtonVariant.success,
          onPressed: () => _showAddDialog(locale),
        ),
        AppButton(
          label: AppStrings.get('edit', locale),
          icon: Icons.edit_rounded,
          variant: AppButtonVariant.purple,
          onPressed: () {},
        ),
        AppButton(
          label: AppStrings.get('delete', locale),
          icon: Icons.delete_rounded,
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _statusBadge(String status, String locale) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = AppColors.success;
        label = AppStrings.get('active', locale);
        break;
      case 'inactive':
        color = AppColors.danger;
        label = AppStrings.get('inactive', locale);
        break;
      default:
        color = AppColors.warning;
        label = AppStrings.get('expired', locale);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildFooter(String locale) {
    return Center(
      child: Text(
        AppStrings.get('copyright', locale),
        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
      ),
    );
  }

  void _showAddDialog(String locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppStrings.get('add', locale)} - ${AppStrings.get('fleet', locale)}'),
        content: Text(AppStrings.get('feature_coming_soon', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel', locale)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<AppVehicle> items, String locale, DateFormat format) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final v = items[index];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${v.id} - ${v.model}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  _statusBadge(v.status, locale),
                ],
              ),
              const Divider(height: 24),
              _mobileRow(AppStrings.get('plate_number', locale), v.plateNumber),
              _mobileRow(AppStrings.get('base_number', locale), v.baseNumber),
              _mobileRow(AppStrings.get('card_number', locale), v.cardNumber),
              _mobileRow(AppStrings.get('issue_date', locale), format.format(v.issueDate)),
              _mobileRow(AppStrings.get('expiry_date', locale), format.format(v.expiryDate)),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
