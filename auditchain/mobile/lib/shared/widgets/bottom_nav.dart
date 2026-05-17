import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/auditorias/presentation/historial_screen.dart';
import '../../features/auditorias/presentation/nueva_auditoria_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class AuditorBottomNav extends StatefulWidget {
  const AuditorBottomNav({super.key});

  @override
  State<AuditorBottomNav> createState() => _AuditorBottomNavState();
}

class _AuditorBottomNavState extends State<AuditorBottomNav> {
  int _tab = 0;

  static const _screens = [
    AuditorDashboardScreen(),
    AuditorHistoryScreen(),
    NuevaAuditoriaScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1E3A8A).withAlpha(26),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1E3A8A)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.assignment_rounded, color: Color(0xFF06B6D4)),
            label: 'Audits',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF06B6D4)),
            label: 'Nueva',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8)),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1E3A8A)),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
