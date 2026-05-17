import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auditorias/presentation/historial_screen.dart';
import '../../features/auditorias/presentation/nueva_auditoria_screen.dart';
import '../../features/auditorias/presentation/reporte_screen.dart';
import '../../features/evidencias/presentation/evidencias_screen.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/bottom_nav.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const AuditorBottomNav());
      case '/historial':
        return MaterialPageRoute(builder: (_) => const AuditorHistoryScreen());
      case '/nueva-auditoria':
        return MaterialPageRoute(
            builder: (_) => const NuevaAuditoriaScreen(),
            fullscreenDialog: true);
      case '/reporte':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReporteScreen(
            auditoria: args['auditoria'] as Auditoria,
            sucursalNombre: args['sucursalNombre'] as String? ?? 'Sucursal',
            auditorNombre: args['auditorNombre'] as String? ?? 'Auditor',
          ),
        );
      case '/evidencias':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EvidenciasScreen(
            auditoria: args['auditoria'] as Auditoria,
            sucursalNombre: args['sucursalNombre'] as String? ?? 'Sucursal',
          ),
        );
      case '/login':
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
