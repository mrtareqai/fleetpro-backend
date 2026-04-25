import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/providers/locale_provider.dart';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  String _searchQuery = '';
  final List<Tenant> _companies = List.from(MockData.tenants);

  void _addCompany(Tenant t) {
    setState(() => _companies.add(t));
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMobile = MediaQuery.of(context).size.width < 800;

    var filtered = _companies;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.name.contains(_searchQuery) ||
              t.serverId.contains(_searchQuery))
          .toList();
    }

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
                AppStrings.get('companies_management', locale),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Wrap(
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
                  AppButton(
                    label: AppStrings.get('add', locale),
                    icon: Icons.business_rounded,
                    variant: AppButtonVariant.success,
                    onPressed: () => _showAddCompanyDialog(locale),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: filtered.isEmpty
                      ? Center(child: Text(AppStrings.get('no_data', locale)))
                      : isMobile
                          ? _buildMobileList(filtered, locale)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
                                  columns: [
                                    DataColumn(label: Text(AppStrings.get('company_name', locale))),
                                    DataColumn(label: Text(AppStrings.get('server_id', locale))),
                                    DataColumn(label: Text(AppStrings.get('contact', locale))),
                                    DataColumn(label: Text(AppStrings.get('email', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                    DataColumn(label: Text(AppStrings.get('actions', locale))),
                                  ],
                                  rows: filtered.map((c) {
                                    return DataRow(cells: [
                                      DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      DataCell(Text(c.serverId, style: const TextStyle(color: AppColors.primary))),
                                      DataCell(Text(c.phone)),
                                      DataCell(Text(c.email)),
                                      DataCell(_statusBadge(c.isActive, locale)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Switch(
                                              value: c.isActive,
                                              activeTrackColor: AppColors.success,
                                              onChanged: (val) {
                                                setState(() => c.isActive = val);
                                              },
                                            ),
                                          ],
                                        ),
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

  Widget _buildMobileList(List<Tenant> companies, String locale) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: companies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = companies[index];
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
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  _statusBadge(c.isActive, locale),
                ],
              ),
              const Divider(height: 24),
              _mobileRow(AppStrings.get('server_id', locale), c.serverId, isPrimary: true),
              _mobileRow(AppStrings.get('contact', locale), c.phone),
              _mobileRow(AppStrings.get('email', locale), c.email),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('status', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Switch(
                    value: c.isActive,
                    activeTrackColor: AppColors.success,
                    onChanged: (val) {
                      setState(() => c.isActive = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isPrimary ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive, String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppStrings.get(isActive ? 'active' : 'inactive', locale),
        style: TextStyle(
            color: isActive ? AppColors.success : AppColors.danger,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showAddCompanyDialog(String locale) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(AppStrings.get('add', locale)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(controller: nameCtrl, hintText: AppStrings.get('company_name', locale)),
                  const SizedBox(height: 10),
                  AppTextField(controller: contactCtrl, hintText: AppStrings.get('contact', locale)),
                  const SizedBox(height: 10),
                  AppTextField(controller: emailCtrl, hintText: AppStrings.get('email', locale)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.get('cancel', locale), style: const TextStyle(color: AppColors.textSecondary)),
              ),
              AppButton(
                label: AppStrings.get('add', locale),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    final newCompany = Tenant(
                      id: 't${_companies.length + 1}',
                      serverId: 'FLT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      name: nameCtrl.text,
                      ownerName: 'المالك', 
                      phone: contactCtrl.text,
                      isActive: true,
                      email: emailCtrl.text,
                    );
                    _addCompany(newCompany);
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
