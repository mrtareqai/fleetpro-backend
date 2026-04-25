import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final transactionsState = ref.watch(transactionsProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('transactions', locale),
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
                  child: transactionsState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, st) => Center(child: Text('Error: $err')),
                    data: (transactions) {
                      var items = transactions;
                      if (_searchQuery.isNotEmpty) {
                        items = items.where((t) => t.description.contains(_searchQuery) || t.category.contains(_searchQuery)).toList();
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
                                    DataColumn(label: Text(AppStrings.get('type', locale))),
                                    DataColumn(label: Text(AppStrings.get('amount', locale))),
                                    DataColumn(label: Text(AppStrings.get('category', locale))),
                                    DataColumn(label: Text(AppStrings.get('date', locale))),
                                    DataColumn(label: Text(AppStrings.get('description', locale))),
                                  ],
                                  rows: items.map((t) {
                                    final dt = DateFormat('yyyy-MM-dd HH:mm').format(t.date);
                                    final isIncome = t.type == 'income';
                                    return DataRow(cells: [
                                      DataCell(Text('${t.id}')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isIncome ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(AppStrings.get(t.type, locale),
                                              style: TextStyle(color: isIncome ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                      DataCell(Text('${t.amount}', style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.success : AppColors.danger))),
                                      DataCell(Text(AppStrings.get(t.category, locale))),
                                      DataCell(Text(dt)),
                                      DataCell(Text(t.description)),
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

  Widget _buildMobileList(List<AppTransaction> items, String locale) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = items[index];
        final dt = DateFormat('yyyy-MM-dd HH:mm').format(t.date);
        final isIncome = t.type == 'income';

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
                  Text(AppStrings.get(t.category, locale), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(
                    '${isIncome ? '+' : '-'}${t.amount}', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? AppColors.success : AppColors.danger, fontSize: 16)
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(dt, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
