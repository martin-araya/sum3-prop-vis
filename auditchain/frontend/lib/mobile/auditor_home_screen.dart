import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'auditor_dashboard_screen.dart';
import 'auditor_history_screen.dart';

class AuditorHomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const AuditorHomeScreen({super.key, required this.onLogout});

  @override
  State<AuditorHomeScreen> createState() => _AuditorHomeScreenState();
}

class _AuditorHomeScreenState extends State<AuditorHomeScreen> {
  int _tab = 0;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AuditorDashboardScreen(user: _user, onLogout: _logout),
      const AuditorHistoryScreen(),
    ];

    return Scaffold(
      body: screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1E3A8A).withAlpha(26),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF94A3B8)),
            selectedIcon:
                const Icon(Icons.home_rounded, color: Color(0xFF1E3A8A)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined,
                color: Color(0xFF94A3B8)),
            selectedIcon: const Icon(Icons.assignment_rounded,
                color: Color(0xFF06B6D4)),
            label: 'Audits',
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
Widget _navLabel(String t) =>
    Text(t, style: GoogleFonts.inter(fontSize: 11));
