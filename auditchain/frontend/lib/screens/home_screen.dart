import 'package:flutter/material.dart';
import 'sucursales_screen.dart';
import 'auditores_screen.dart';
import 'auditorias_screen.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.store, label: 'Sucursales'),
    _NavItem(icon: Icons.person_search, label: 'Auditores'),
    _NavItem(icon: Icons.assignment, label: 'Auditorías'),
    _NavItem(icon: Icons.manage_accounts, label: 'Usuarios'),
  ];

  final List<Widget> _screens = [
    const SucursalesScreen(),
    const AuditoresScreen(),
    const AuditoriasScreen(),
    const UsuariosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── SIDEBAR ────────────────────────────────────────────────────────
          Container(
            width: 220,
            color: const Color(0xFF1A1A2E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF2D2D4E))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4D8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('AC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AuditChain', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('ADMIN PANEL', style: TextStyle(color: Color(0xFF888888), fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text('PRINCIPAL', style: TextStyle(color: Color(0xFF666666), fontSize: 10, letterSpacing: 1)),
                ),
                // Nav items
                ...List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isSelected = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2D2D4E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18, color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFAAAAAA)),
                          const SizedBox(width: 10),
                          Text(item.label, style: TextStyle(color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFAAAAAA), fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // ── MAIN CONTENT ───────────────────────────────────────────────────
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
