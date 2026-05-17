import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/dio_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _notificaciones = true;
  bool _modoOffline = false;
  bool _soloWifi = true;

  @override
  void initState() {
    super.initState();
    AuthClient.getUser().then((u) => setState(() => _user = u));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
            'Los datos no sincronizados se perderán del dispositivo local.',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Cerrar sesión', style: GoogleFonts.inter()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
    if (confirm == true) {
      await AuthClient.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _user?['nombre'] as String? ?? 'Auditor';
    final email = _user?['email'] as String? ?? '';
    final rol = _user?['rol'] as String? ?? 'auditor';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: const Color(0xFF0A2540),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF0A2540)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF06B6D4),
                            child: Text(inicial,
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombre,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                Text(email,
                                    style: GoogleFonts.inter(
                                        color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Row(children: [
                                  _badge(Icons.verified_user_outlined,
                                      rol[0].toUpperCase() + rol.substring(1)),
                                  const SizedBox(width: 8),
                                  _badge(Icons.location_on_outlined, 'Región Metro'),
                                ]),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildSyncCard(),
                const SizedBox(height: 12),
                _buildPrefsCard(),
                const SizedBox(height: 12),
                _buildLogoutCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: const Color(0xFF06B6D4)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _buildSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.sync_rounded, color: Color(0xFF1E3A8A), size: 18),
          const SizedBox(width: 8),
          Text('Cola de sincronización',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A2540))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('3 pendientes',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E))),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Estado de los datos locales vs servidor.',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Text('Sincronizando auditoría "Sucursal Centro"... 68%',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.68,
            backgroundColor: Color(0xFFE2E8F0),
            color: Color(0xFF1E3A8A),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: Text('Sincronizar ahora',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPrefsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.tune_rounded, color: Color(0xFF1E3A8A), size: 18),
          const SizedBox(width: 8),
          Text('Preferencias de App',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A2540))),
        ]),
        const SizedBox(height: 12),
        _toggle(
          Icons.notifications_outlined,
          'Notificaciones',
          _notificaciones,
          (v) => setState(() => _notificaciones = v),
        ),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        _toggle(
          Icons.wifi_off_rounded,
          'Modo Offline',
          _modoOffline,
          (v) => setState(() => _modoOffline = v),
        ),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        _toggle(
          Icons.wifi_rounded,
          'Carga solo con Wi-Fi',
          _soloWifi,
          (v) => setState(() => _soloWifi = v),
          subtitle: 'Recomendado para datos grandes',
        ),
      ]),
    );
  }

  Widget _toggle(IconData icon, String label, bool value,
      ValueChanged<bool> onChanged, {String? subtitle}) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF64748B)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF0A2540))),
          if (subtitle != null)
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF94A3B8))),
        ]),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF1E3A8A),
        activeTrackColor: const Color(0xFF1E3A8A).withAlpha(80),
      ),
    ]);
  }

  Widget _buildLogoutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Gestión de Sesión',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF991B1B))),
        const SizedBox(height: 4),
        Text('Cerrar sesión eliminará los datos no sincronizados del dispositivo local.',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 18),
            label: Text('Cerrar Sesión',
                style: GoogleFonts.inter(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }
}
