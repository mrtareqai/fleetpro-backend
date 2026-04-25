import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/reservations_provider.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    final reservationsState = ref.watch(reservationsProvider);

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
                AppStrings.get('reservations_management', locale),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                  child: reservationsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, st) => Center(child: Text('Error: $err')),
                    data: (reservations) {
                      var items = reservations;
                      if (_statusFilter != 'all') {
                        items = items.where((r) => r.status == _statusFilter).toList();
                      }
                      if (_searchQuery.isNotEmpty) {
                        items = items.where((r) =>
                            r.clientName.contains(_searchQuery) ||
                            r.id.toString().contains(_searchQuery)).toList();
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
                                    DataColumn(label: Text(AppStrings.get('id', locale))),
                                    DataColumn(label: Text(AppStrings.get('client_name', locale))),
                                    DataColumn(label: Text(AppStrings.get('date', locale))),
                                    DataColumn(label: Text(AppStrings.get('trip', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                  ],
                                  rows: items.map((r) {
                                    return DataRow(cells: [
                                      DataCell(Text('${r.id}')),
                                      DataCell(Text(r.clientName)),
                                      DataCell(Text(dateFormat.format(r.pickupDate))),
                                      DataCell(Text(r.destination)),
                                      DataCell(_statusBadge(r.status, locale)),
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
              Center(
                child: Text(AppStrings.get('copyright', locale),
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusFilter,
              items: [
                DropdownMenuItem(value: 'all', child: Text(AppStrings.get('all', locale))),
                DropdownMenuItem(value: 'active', child: Text(AppStrings.get('active', locale))),
                DropdownMenuItem(value: 'completed', child: Text(AppStrings.get('completed', locale))),
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
          onPressed: () {},
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
    Color color = status == 'active' ? AppColors.success : AppColors.warning;
    String label = AppStrings.get(status, locale);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildMobileList(List<AppReservation> items, String locale, DateFormat format) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = items[index];
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
                    r.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  _statusBadge(r.status, locale),
                ],
              ),
              const SizedBox(height: 8),
              _mobileRow('ID', '${r.id}'),
              _mobileRow(AppStrings.get('trip', locale), r.destination),
              _mobileRow(AppStrings.get('date', locale), format.format(r.pickupDate)),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
