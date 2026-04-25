
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sidebar_widget.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/force_change_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/fleet/presentation/screens/fleet_screen.dart';
import '../../features/reservations/presentation/screens/reservations_screen.dart';
import '../../features/tickets/presentation/screens/tickets_screen.dart';
import '../../features/drivers/presentation/screens/drivers_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/roles/presentation/screens/roles_screen.dart';
import '../../features/topowner/presentation/screens/topowner_dashboard_screen.dart';
import '../../features/topowner/presentation/screens/companies_screen.dart';
import '../../features/topowner/presentation/screens/firewall_screen.dart';
import '../../features/topowner/presentation/screens/audit_log_screen.dart';

import '../../features/routes/presentation/screens/routes_screen.dart';
import '../../features/branches_agents/presentation/screens/branches_agents_screen.dart';
import '../../features/trips/presentation/screens/trips_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/movements/presentation/screens/movements_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoginPage = state.uri.toString() == '/login';
      final isChangePwd = state.uri.toString() == '/change-password';
      final isForceChange =
          authState.status == AuthStatus.forceChangePassword;

      // Not authenticated and not on login page → go to login
      if (!isAuth && !isForceChange && !isLoginPage) {
        return '/login';
      }

      // Force change password → redirect there
      if (isForceChange && !isChangePwd) {
        return '/change-password';
      }

      // Authenticated but on login page → redirect to dashboard
      if (isAuth && isLoginPage) {
        if (authState.isTopOwner) return '/topowner';
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // ─── Auth Routes ───
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ForceChangePasswordScreen(),
      ),

      // ─── Tenant Shell (with sidebar) ───
      ShellRoute(
        builder: (context, state, child) =>
            ShellWithSidebar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RoutesScreen(),
          ),
          GoRoute(
            path: '/branches-agents',
            builder: (context, state) => const BranchesAgentsScreen(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripsScreen(),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) => const ReservationsScreen(),
          ),
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketsScreen(),
          ),
          GoRoute(
            path: '/fleet',
            builder: (context, state) => const FleetScreen(),
          ),
          GoRoute(
            path: '/drivers',
            builder: (context, state) => const DriversScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/movement',
            builder: (context, state) => const MovementsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/roles',
            builder: (context, state) => const RolesScreen(),
          ),
        ],
      ),

      // ─── TopOwner Shell (with sidebar) ───
      ShellRoute(
        builder: (context, state, child) =>
            ShellWithSidebar(isTopOwner: true, child: child),
        routes: [
          GoRoute(
            path: '/topowner',
            builder: (context, state) => const TopOwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/topowner/companies',
            builder: (context, state) => const CompaniesScreen(),
          ),
          GoRoute(
            path: '/topowner/users',
            builder: (context, state) =>
                const UsersScreen(isTopOwner: true),
          ),
          GoRoute(
            path: '/topowner/firewall',
            builder: (context, state) => const FirewallScreen(),
          ),
          GoRoute(
            path: '/topowner/audit',
            builder: (context, state) => const AuditLogScreen(),
          ),
        ],
      ),
    ],
  );
});
