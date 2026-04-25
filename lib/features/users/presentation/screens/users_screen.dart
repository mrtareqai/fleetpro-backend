import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/users_provider.dart';
import '../../../roles/domain/providers/roles_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  final bool isTopOwner;
  const UsersScreen({super.key, this.isTopOwner = false});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {

  void _showAddEditUserDialog(BuildContext context, String locale, {AppUserModel? user}) {
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final passwordCtrl = TextEditingController();
    
    String? selectedRole = user?.role;
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgLight,
              title: Text(user == null ? 'إضافة مستخدم' : 'تعديل المستخدم', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameCtrl,
                        decoration: const InputDecoration(labelText: 'اسم المستخدم', border: OutlineInputBorder()),
                        enabled: user == null, // لا يمكن تغيير اليوزرنيم بعد الإنشاء
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: user == null ? 'كلمة المرور' : 'كلمة المرور الجديدة (اختياري)', 
                          border: const OutlineInputBorder()
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final rolesState = ref.watch(rolesProvider);
                          return rolesState.maybeWhen(
                            data: (roles) {
                              if (roles.isEmpty) return const Text('يجب إضافة أدوار أولاً');
                              
                              selectedRole ??= roles.first.name;
                              
                              return DropdownButtonFormField<String>(
                                initialValue: roles.any((r) => r.name == selectedRole) ? selectedRole : roles.first.name,
                                decoration: const InputDecoration(labelText: 'الدور', border: OutlineInputBorder()),
                                items: roles.map((role) {
                                  return DropdownMenuItem(
                                    value: role.name,
                                    child: Text(locale == 'ar' ? role.nameAr : role.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => selectedRole = val);
                                },
                              );
                            },
                            orElse: () => const CircularProgressIndicator(),
                          );
                        }
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('حالة الحساب (نشط/معطل)'),
                        value: isActive,
                        onChanged: (val) {
                          setState(() => isActive = val);
                        },
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel', locale))),
                ElevatedButton(
                  onPressed: () async {
                    if (usernameCtrl.text.isEmpty || selectedRole == null) return;
                    if (user == null && passwordCtrl.text.isEmpty) return; // مطلوب عند الإنشاء

                    final data = {
                      'username': usernameCtrl.text,
                      'displayName': nameCtrl.text,
                      'role': selectedRole,
                      'isActive': isActive,
                      if (passwordCtrl.text.isNotEmpty) 'password': passwordCtrl.text,
                    };
                    
                    if (user == null) {
                      await ref.read(usersProvider.notifier).addUser(data);
                    } else {
                      await ref.read(usersProvider.notifier).updateUser(user.id, data);
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
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    final usersState = ref.watch(usersProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('users_management', locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppButton(
                    label: AppStrings.get('add_user', locale),
                    icon: Icons.person_add_rounded,
                    variant: AppButtonVariant.success,
                    onPressed: () => _showAddEditUserDialog(context, locale),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.read(usersProvider.notifier).fetchUsers(),
                  )
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
                  child: usersState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('خطأ: $err')),
                    data: (users) {
                      if (users.isEmpty) return const Center(child: Text('لا يوجد مستخدمين'));
                      
                      return isMobile
                          ? _buildMobileList(users, locale)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.bgLight.withValues(alpha: 0.5)),
                                  columns: [
                                    DataColumn(label: Text(AppStrings.get('id', locale))),
                                    DataColumn(label: Text(AppStrings.get('username', locale))),
                                    DataColumn(label: Text('الاسم')),
                                    DataColumn(label: Text(AppStrings.get('role', locale))),
                                    DataColumn(label: Text(AppStrings.get('status', locale))),
                                    const DataColumn(label: Text('إجراءات')),
                                  ],
                                  rows: users.asMap().entries.map((entry) {
                                    final u = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text('${entry.key + 1}')),
                                      DataCell(Text(u.username)),
                                      DataCell(Text(u.displayName)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _roleColor(u.role).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(u.role, style: TextStyle(color: _roleColor(u.role), fontSize: 12, fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                      DataCell(_statusBadge(u.isActive, locale)),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                            onPressed: () => _showAddEditUserDialog(context, locale, user: u),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                                            onPressed: () {
                                              ref.read(usersProvider.notifier).deleteUser(u.id);
                                            },
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                    }
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<AppUserModel> usersList, String locale) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: usersList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final u = usersList[index];
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
                  Text(u.username, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Row(
                    children: [
                      _statusBadge(u.isActive, locale),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                        onPressed: () => _showAddEditUserDialog(context, locale, user: u),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                        onPressed: () => ref.read(usersProvider.notifier).deleteUser(u.id),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(u.displayName, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.get('role', locale), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(u.role, style: TextStyle(color: _roleColor(u.role), fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
        );
      },
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
        style: TextStyle(color: isActive ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primary;
      case 'operator':
        return AppColors.purple;
      case 'driver':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
