import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auditorias/presentation/historial_screen.dart';
import '../../shared/widgets/bottom_nav.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const AuditorBottomNav());
      case '/historial':
        return MaterialPageRoute(builder: (_) => const AuditorHistoryScreen());
      case '/login':
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
