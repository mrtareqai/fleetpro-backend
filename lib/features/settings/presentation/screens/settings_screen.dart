import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showChangePasswordDialog(BuildContext context, String locale) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgLight,
              title: Text(AppStrings.get('change_password', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMsg != null) ...[
                      Text(errorMsg!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: currentPassCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: locale == 'ar' ? 'كلمة المرور الحالية' : 'Current Password', border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: locale == 'ar' ? 'كلمة المرور الجديدة' : 'New Password', border: const OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel', locale))),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (currentPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) return;
                    setState(() { isLoading = true; errorMsg = null; });
                    final errorMsgResult = await ref.read(authProvider.notifier).changePassword(
                      currentPassword: currentPassCtrl.text,
                      newPassword: newPassCtrl.text,
                    );
                    if (!mounted) return;
                    if (errorMsgResult == null) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(locale == 'ar' ? 'تم التغيير بنجاح' : 'Changed successfully')));
                    } else {
                      setState(() { isLoading = false; errorMsg = errorMsgResult; });
                    }
                  },
                  child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(AppStrings.get('save', locale)),
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
    final isDark = ref.watch(themeProvider);

    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('settings_title', locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // Profile
              _settingsCard(
                icon: Icons.person_rounded,
                title: AppStrings.get('user_management', locale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.watch(authProvider).user?.displayName ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(ref.watch(authProvider).user?.role ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showChangePasswordDialog(context, locale),
                      icon: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                      label: Text(AppStrings.get('change_password', locale), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Language
              _settingsCard(
                icon: Icons.language_rounded,
                title: AppStrings.get('language', locale),
                child: Row(
                  children: [
                    _langChip(locale == 'ar', 'العربية', () {
                      ref.read(localeProvider.notifier).state = 'ar';
                    }),
                    const SizedBox(width: 8),
                    _langChip(locale == 'en', 'English', () {
                      ref.read(localeProvider.notifier).state = 'en';
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Theme
              _settingsCard(
                icon: Icons.palette_rounded,
                title: AppStrings.get('theme', locale),
                child: SwitchListTile(
                  title: Text(AppStrings.get('dark_mode', locale)),
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).state = val;
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),

              // About
              _settingsCard(
                icon: Icons.info_outline_rounded,
                title: AppStrings.get('about', locale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FleetPro Management System',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('${AppStrings.get('version', locale)}: 1.0.0',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(AppStrings.get('copyright', locale),
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _langChip(bool isActive, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
