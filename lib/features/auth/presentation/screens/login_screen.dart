import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _serverIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _companyName;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animController.dispose();
    _serverIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onServerIdChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (value.trim().isEmpty) {
      setState(() => _companyName = null);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final auth = ref.read(authProvider.notifier);
      final name = await auth.validateServerId(value);
      if (mounted) {
        setState(() => _companyName = name);
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).clearError();

    await ref.read(authProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          serverId: _serverIdController.text.trim().isEmpty
              ? null
              : _serverIdController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(authProvider);

    if (state.status == AuthStatus.authenticated) {
      if (state.isTopOwner) {
        context.go('/topowner');
      } else {
        context.go('/dashboard');
      }
    } else if (state.status == AuthStatus.forceChangePassword) {
      context.go('/change-password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    
    return Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: isDesktop ? _buildDesktopLayout(locale) : _buildMobileLayout(locale),
      ),
    );
  }

  Widget _buildDesktopLayout(String locale) {
    return Row(
      children: [
        // ─── Left Panel (Branding / Visual) ───
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4318FF), Color(0xFF2B0A9B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Abstract background pattern
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'FleetPro',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('app_subtitle', locale),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Decorative analytics or stat showcase
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.rocket_launch_rounded, color: AppColors.accent, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.get('welcome', locale),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.get('manage_fleet', locale),
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ─── Right Panel (Form) ───
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildForm(locale, isDesktop: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(String locale) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: _buildForm(locale, isDesktop: false),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(String locale, {required bool isDesktop}) {
    final authState = ref.watch(authProvider);
    
    return Container(
      padding: isDesktop ? const EdgeInsets.all(40) : const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7090B0).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Language + Mobile Logo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref.read(localeProvider.notifier).state =
                        locale == 'ar' ? 'en' : 'ar';
                  },
                  icon: const Icon(Icons.language_rounded, size: 18),
                  label: Text(
                    locale == 'ar' ? 'English' : 'العربية',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                if (!isDesktop)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FleetPro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.airport_shuttle_rounded, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              AppStrings.get('secure_login', locale),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('welcome', locale),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Server ID Field
            AppTextField(
              controller: _serverIdController,
              hintText: AppStrings.get('server_id', locale),
              prefixIcon: Icons.dns_rounded,
              onChanged: _onServerIdChanged,
            ),
            
            if (_companyName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _companyName!,
                          style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Username Field
            AppTextField(
              controller: _usernameController,
              hintText: AppStrings.get('username', locale),
              prefixIcon: Icons.person_outline_rounded,
              validator: (val) => val == null || val.isEmpty ? AppStrings.get('field_required', locale) : null,
            ),
            const SizedBox(height: 20),

            // Password Field
            AppTextField(
              controller: _passwordController,
              hintText: AppStrings.get('password', locale),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: AppColors.textLight,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) => val == null || val.isEmpty ? AppStrings.get('field_required', locale) : null,
            ),
            const SizedBox(height: 8),

            // Forgot Password
            Align(
              alignment: locale == 'ar' ? Alignment.centerLeft : Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.get('forgot_password', locale),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (authState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get(authState.errorMessage!, locale),
                            style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          if (authState.remainingAttempts != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.get('attempts_warning', locale).replaceAll('{remaining}', '${authState.remainingAttempts}'),
                              style: const TextStyle(color: AppColors.danger, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Login Button
            AppButton(
              label: AppStrings.get('login', locale),
              onPressed: _handleLogin,
              isLoading: authState.isLoading,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                AppStrings.get('copyright', locale),
                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
