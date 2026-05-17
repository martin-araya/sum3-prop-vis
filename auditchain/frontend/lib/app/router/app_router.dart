import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:auditchain/core/auth/auth_state_notifier.dart';
import 'package:auditchain/core/storage/token_storage.dart';
import 'package:auditchain/features/auth/presentation/pages/login_page.dart';
import 'package:auditchain/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:auditchain/features/branches/presentation/pages/branches_page.dart';
import 'package:auditchain/features/branches/presentation/pages/branch_detail_page.dart';
import 'package:auditchain/features/audits/presentation/pages/audits_page.dart';
import 'package:auditchain/features/auditors/presentation/pages/auditors_page.dart';
import 'package:auditchain/features/shared/widgets/app_sidebar.dart';
import 'package:auditchain/features/shared/widgets/app_topbar.dart';

/// Instancia global del router. Se consume desde [App] vía MaterialApp.router.
final GoRouter goRouter = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,
  refreshListenable: authStateNotifier,
  redirect: (BuildContext context, GoRouterState state) async {
    final bool loggedIn = await TokenStorage.isLoggedIn();
    final bool goingToLogin = state.matchedLocation == '/login';

    if (!loggedIn && !goingToLogin) return '/login';
    if (loggedIn && goingToLogin) return '/dashboard';

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/sucursales',
          name: 'sucursales',
          builder: (context, state) => const BranchesPage(),
          routes: <RouteBase>[
            GoRoute(
              path: ':id',
              name: 'sucursal-detalle',
              builder: (context, state) => BranchDetailPage(
                sucursalId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/audits',
          name: 'audits',
          builder: (context, state) => const AuditsPage(),
        ),
        GoRoute(
          path: '/auditors',
          name: 'auditors',
          builder: (context, state) => const AuditorsPage(),
        ),
      ],
    ),
  ],
);

/// Shell principal de la aplicación autenticada.
/// Layout: Row( AppSidebar, Expanded( Column( AppTopbar, child ) ) ).
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AppSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AppTopbar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
