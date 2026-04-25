import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/models/ticket_model.dart';
import '../../domain/providers/tickets_provider.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isMobile = MediaQuery.of(context).size.width < 800;

    final ticketsState = ref.watch(ticketsProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('ticket_management', locale),
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
                  child: ticketsState.when(
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
                            onPressed: () => ref.read(ticketsProvider.notifier).fetchTickets(),
                            child: const Text('إعادة المحاولة'),
                          )
                        ],
                      ),
                    ),
                    data: (dataItems) {
                      var items = dataItems;

                      if (_statusFilter != 'all') {
                        items = items.where((t) => t.status == _statusFilter).toList();
                      }
                      if (_searchQuery.isNotEmpty) {
                        items = items
                            .where((t) =>
                                t.passengerName.contains(_searchQuery) ||
                                t.ticketNumber.contains(_searchQuery))
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
                                    DataColumn(label: Text(AppStrings.get('id', locale))),
                                    DataColumn(label: Text(AppStrings.get('passenger_name', locale))),
                                    DataColumn(label: Text(AppStrings.get('trip', locale))),
                                    DataColumn(label: Text(AppStrings.get('trip_date', locale))),
                                    DataColumn(label: Text(AppStrings.get('ticket_number', locale))),
                                    DataColumn(label: Text(AppStrings.get('seat_number', locale))),
                                    DataColumn(label: Text(AppStrings.get('time', locale))),
                                    DataColumn(label: Text(AppStrings.get('phone', locale))),
                                    DataColumn(label: Text(AppStrings.get('assigned_to', locale))),
                                    DataColumn(label: Text(AppStrings.get('destination', locale))),
                                  ],
                                  rows: items.map((t) {
                                    return DataRow(cells: [
                                      DataCell(Text(t.id)),
                                      DataCell(Text(t.passengerName)),
                                      DataCell(Text(t.trip)),
                                      DataCell(Text(dateFormat.format(t.tripDate))),
                                      DataCell(Text(t.ticketNumber)),
                                      DataCell(Text(t.seatNumber)),
                                      DataCell(Text(t.time)),
                                      DataCell(Text(t.phone)),
                                      DataCell(Text(t.assignedUser)),
                                      DataCell(Text(t.destination)),
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
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
          onPressed: () {
            ref.read(ticketsProvider.notifier).fetchTickets();
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

  Widget _buildMobileList(List<TicketModel> items, String locale, DateFormat format) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = items[index];
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
              Text(
                t.passengerName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _mobileRow(AppStrings.get('ticket_number', locale), t.ticketNumber),
              _mobileRow(AppStrings.get('trip', locale), t.trip),
              _mobileRow(AppStrings.get('trip_date', locale), format.format(t.tripDate)),
              _mobileRow(AppStrings.get('destination', locale), t.destination),
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
