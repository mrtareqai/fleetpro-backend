import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/providers/trips_provider.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final tripsState = ref.watch(tripsProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('trips_management', locale),
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
                  child: tripsState.when(
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
                            onPressed: () => ref.read(tripsProvider.notifier).fetchTrips(),
                            child: const Text('إعادة المحاولة'),
                          )
                        ],
                      ),
                    ),
                    data: (dataItems) {
                      var items = dataItems;

                      if (_searchQuery.isNotEmpty) {
                        items = items.where((t) {
                          final origin = t.route?['originCity']?.toString() ?? '';
                          final dest = t.route?['destinationCity']?.toString() ?? '';
                          return origin.contains(_searchQuery) || dest.contains(_searchQuery);
                        }).toList();
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
                                    DataColumn(label: Text(AppStrings.get('route', locale))),
                                    DataColumn(label: Text(AppStrings.get('driver', locale))),
                                    DataColumn(label: Text(AppStrings.get('vehicle', locale))),
                                    DataColumn(label: Text(AppStrings.get('departure_time', locale))),
                                    DataColumn(label: Text(AppStrings.get('available_seats', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                  ],
                                  rows: items.map((t) {
                                    final origin = t.route?['originCity'] ?? '-';
                                    final dest = t.route?['destinationCity'] ?? '-';
                                    final routeStr = '$origin - $dest';
                                    final driverName = t.driver?['name'] ?? '-';
                                    final vehiclePlate = t.vehicle?['plateNumber'] ?? '-';
                                    final depTime = DateFormat('yyyy-MM-dd HH:mm').format(t.departureTime);

                                    return DataRow(cells: [
                                      DataCell(Text('${t.id}')),
                                      DataCell(Text(routeStr)),
                                      DataCell(Text(driverName)),
                                      DataCell(Text(vehiclePlate)),
                                      DataCell(Text(depTime)),
                                      DataCell(Text('${t.availableSeats} / ${t.totalSeats}')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.getStatusBg(t.status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(AppStrings.get(t.status, locale),
                                              style: TextStyle(color: AppColors.getStatusColor(t.status), fontSize: 12, fontWeight: FontWeight.w500)),
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
            ref.read(tripsProvider.notifier).fetchTrips();
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

  Widget _buildMobileList(List<TripModel> items, String locale) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = items[index];
        final origin = t.route?['originCity'] ?? '-';
        final dest = t.route?['destinationCity'] ?? '-';
        final routeStr = '$origin ➔ $dest';
        final depTime = DateFormat('yyyy-MM-dd HH:mm').format(t.departureTime);

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
              Text(routeStr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('departure_time', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(depTime, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('available_seats', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('${t.availableSeats} / ${t.totalSeats}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
