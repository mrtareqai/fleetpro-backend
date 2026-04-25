import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/roles_provider.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  final List<String> _availablePages = [
    'dashboard', 'movements', 'trips', 'routes', 'bookings',
    'tickets', 'vehicles', 'drivers', 'expenses', 'reports',
    'users', 'roles', 'settings'
  ];
  
  final List<String> _actions = ['view', 'create', 'update', 'delete'];

  void _showAddEditRoleDialog(BuildContext context, String locale, {AppRoleModel? role}) {
    final nameCtrl = TextEditingController(text: role?.name ?? '');
    final nameArCtrl = TextEditingController(text: role?.nameAr ?? '');
    List<String> selectedPermissions = List.from(role?.permissions ?? []);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgLight,
              title: Text(role == null ? 'إضافة دور جديد' : 'تعديل الدور', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'اسم الدور (English)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameArCtrl,
                        decoration: const InputDecoration(labelText: 'اسم الدور (عربي)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('الصلاحيات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      ..._availablePages.map((page) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get(page, locale), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Wrap(
                                  spacing: 10,
                                  children: _actions.map((action) {
                                    final perm = '$page:$action';
                                    final isSelected = selectedPermissions.contains(perm);
                                    return FilterChip(
                                      label: Text(action, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                                      selected: isSelected,
                                      selectedColor: AppColors.primary,
                                      onSelected: (val) {
                                        setState(() {
                                          if (val) {
                                            selectedPermissions.add(perm);
                                          } else {
                                            selectedPermissions.remove(perm);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel', locale))),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final newRole = AppRoleModel(
                      id: role?.id ?? '',
                      name: nameCtrl.text,
                      nameAr: nameArCtrl.text.isEmpty ? nameCtrl.text : nameArCtrl.text,
                      permissions: selectedPermissions,
                    );
                    
                    if (role == null) {
                      await ref.read(rolesProvider.notifier).addRole(newRole);
                    } else {
                      await ref.read(rolesProvider.notifier).updateRole(role.id, newRole);
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: Text(AppStrings.get('save', locale)),
                )
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final rolesState = ref.watch(rolesProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('roles_management', locale),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  AppButton(
                    label: 'إضافة دور جديد',
                    icon: Icons.security,
                    onPressed: () => _showAddEditRoleDialog(context, locale),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: rolesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('خطأ: $err')),
                  data: (roles) {
                    if (roles.isEmpty) {
                      return const Center(child: Text('لا توجد أدوار مضافة'));
                    }
                    return ListView.builder(
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            locale == 'ar' ? role.nameAr : role.name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${role.permissions.length} ${AppStrings.get('permissions', locale)}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                        onPressed: () => _showAddEditRoleDialog(context, locale, role: role),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                                        onPressed: () {
                                          ref.read(rolesProvider.notifier).deleteRole(role.id);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: role.permissions.map((p) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(p, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
