import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../../shared/providers/locale_provider.dart';
import '../../features/auth/domain/providers/auth_provider.dart';

class SidebarItem {
  final String key;
  final IconData icon;
  final String route;
  final bool isSection;

  const SidebarItem({
    required this.key,
    required this.icon,
    required this.route,
    this.isSection = false,
  });
}

class SidebarWidget extends ConsumerWidget {
  final bool isTopOwner;

  const SidebarWidget({super.key, this.isTopOwner = false});

  List<SidebarItem> get _tenantItems => const [
        SidebarItem(key: 'dashboard', icon: Icons.home_rounded, route: '/dashboard'),
        SidebarItem(key: 'routes', icon: Icons.map_rounded, route: '/routes'),
        SidebarItem(key: 'branches_agents', icon: Icons.store_rounded, route: '/branches-agents'),
        SidebarItem(key: 'trips', icon: Icons.directions_transit_rounded, route: '/trips'),
        SidebarItem(key: 'reservations', icon: Icons.calendar_month_rounded, route: '/reservations'),
        SidebarItem(key: 'tickets', icon: Icons.confirmation_number_rounded, route: '/tickets'),
        SidebarItem(key: 'fleet', icon: Icons.directions_bus_rounded, route: '/fleet'),
        SidebarItem(key: 'drivers', icon: Icons.people_rounded, route: '/drivers'),
        SidebarItem(key: 'reports', icon: Icons.bar_chart_rounded, route: '/reports'),
        SidebarItem(key: 'movement', icon: Icons.route_rounded, route: '/movement'),
        SidebarItem(key: 'expenses', icon: Icons.account_balance_wallet_rounded, route: '/expenses'),
        SidebarItem(key: 'transactions', icon: Icons.attach_money_rounded, route: '/transactions'),
        SidebarItem(key: 'notifications', icon: Icons.notifications_rounded, route: '/notifications'),
        SidebarItem(key: 'settings', icon: Icons.tune_rounded, route: '/settings'),
        // Section: Administration
        SidebarItem(key: 'administration', icon: Icons.admin_panel_settings, route: '', isSection: true),
        SidebarItem(key: 'user_management', icon: Icons.people_outline_rounded, route: '/users'),
        SidebarItem(key: 'roles_permissions', icon: Icons.security_rounded, route: '/roles'),
      ];

  List<SidebarItem> get _topOwnerItems => const [
        SidebarItem(key: 'dashboard', icon: Icons.home_rounded, route: '/topowner'),
        SidebarItem(key: 'companies', icon: Icons.business_rounded, route: '/topowner/companies'),
        SidebarItem(key: 'all_users', icon: Icons.people_rounded, route: '/topowner/users'),
        SidebarItem(key: 'firewall', icon: Icons.shield_rounded, route: '/topowner/firewall'),
        SidebarItem(key: 'audit_logs', icon: Icons.history_rounded, route: '/topowner/audit'),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final items = isTopOwner ? _topOwnerItems : _tenantItems;
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
      ),
      child: Column(
        children: [
          // ─── Logo Header ───
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FleetPro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      AppStrings.get('app_subtitle', locale),
                      style: TextStyle(
                        color: AppColors.sidebarText.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.sidebarHover, height: 1),

          // ─── Tenant Name (if applicable) ───
          if (!isTopOwner && authState.tenant != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authState.tenant!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ─── Menu Items ───
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item.isSection) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      AppStrings.get(item.key, locale),
                      style: TextStyle(
                        color: AppColors.sidebarSection,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }

                final isActive = currentRoute == item.route;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (item.route.isNotEmpty) {
                          context.go(item.route);
                        }
                      },
                      hoverColor: AppColors.sidebarHover,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.sidebarActive
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isActive
                              ? Border(
                                  right: locale == 'ar'
                                      ? BorderSide.none
                                      : const BorderSide(
                                          color: AppColors.primary,
                                          width: 3,
                                        ),
                                  left: locale == 'ar'
                                      ? const BorderSide(
                                          color: AppColors.primary,
                                          width: 3,
                                        )
                                      : BorderSide.none,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.sidebarText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppStrings.get(item.key, locale),
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.sidebarActiveText
                                      : AppColors.sidebarText,
                                  fontSize: 13,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Bottom Section ───
          const Divider(color: AppColors.sidebarHover, height: 1),

          // Language Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  ref.read(localeProvider.notifier).state =
                      locale == 'ar' ? 'en' : 'ar';
                },
                hoverColor: AppColors.sidebarHover,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: AppColors.sidebarText,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale == 'ar' ? 'English' : 'العربية',
                        style: const TextStyle(
                          color: AppColors.sidebarText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                hoverColor: AppColors.danger.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.get('logout', locale),
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shell layout that wraps pages with Sidebar
class ShellWithSidebar extends ConsumerWidget {
  final Widget child;
  final bool isTopOwner;

  const ShellWithSidebar({
    super.key,
    required this.child,
    this.isTopOwner = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    if (isMobile) {
      return Scaffold(
        drawer: SidebarWidget(isTopOwner: isTopOwner),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'FleetPro',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SidebarWidget(isTopOwner: isTopOwner),
          Expanded(child: child),
        ],
      ),
    );
  }
}
