import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class AuditorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onLogout;
  const AuditorDashboardScreen(
      {super.key, this.user, required this.onLogout});

  @override
  State<AuditorDashboardScreen> createState() =>
      _AuditorDashboardScreenState();
}

class _AuditorDashboardScreenState extends State<AuditorDashboardScreen> {
  List<Auditoria> _auditorias = [];
  List<Sucursal> _sucursales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getAuditorias(),
        ApiService.getSucursales(),
      ]);
      setState(() {
        _auditorias = results[0] as List<Auditoria>;
        _sucursales = results[1] as List<Sucursal>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  List<Auditoria> get _hoy {
    final now = DateTime.now();
    final s =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _auditorias.where((a) => a.fecha == s).toList();
  }

  List<Auditoria> get _semana {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return _auditorias.where((a) {
      try {
        final p = a.fecha.split('-');
        final d = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        return !d.isBefore(DateTime(start.year, start.month, start.day));
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int get _completadas =>
      _auditorias.where((a) => a.estado == 'completada').length;
  int get _pendientes =>
      _auditorias.where((a) => a.estado == 'pendiente').length;
  int get _conObs =>
      _auditorias.where((a) => a.estado == 'con_observaciones').length;

  double get _promedio {
    final con = _auditorias.where((a) => a.puntaje > 0).toList();
    if (con.isEmpty) return 0;
    return con.map((a) => a.puntaje.toDouble()).reduce((a, b) => a + b) /
        con.length;
  }

  List<Sucursal> get _proximas => _sucursales
      .where((s) => s.estado == 'activo')
      .take(3)
      .toList();

  @override
  Widget build(BuildContext context) {
    final nombre =
        (widget.user?['nombre'] as String? ?? 'Auditor').split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(nombre),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildKpiGrid(),
                        const SizedBox(height: 16),
                        _buildProgressCard(),
                        const SizedBox(height: 16),
                        _buildPieCard(),
                        const SizedBox(height: 16),
                        _buildProximasSection(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showSnack(context, 'Nueva auditoría — próximamente'),
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  SliverAppBar _buildAppBar(String nombre) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A2540),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFF0A2540),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auditor Regional',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF06B6D4),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text(widget.user?['nombre'] as String? ?? 'Auditor',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Color(0xFF9FB3C8)),
                onPressed: _cargar,
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Color(0xFF9FB3C8)),
                onPressed: widget.onLogout,
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return Row(
      children: [
        Expanded(
            child: _kpi('HOY', '${_hoy.length}',
                Icons.today_rounded, const Color(0xFF1E3A8A),
                'En progreso')),
        const SizedBox(width: 10),
        Expanded(
            child: _kpi('SEMANAL', '${_semana.length}',
                Icons.date_range_rounded, const Color(0xFF06B6D4),
                'De ${_auditorias.length} total')),
        const SizedBox(width: 10),
        Expanded(
            child: _kpi('PUNTAJE PROM.', '${_promedio.toStringAsFixed(0)}%',
                Icons.bar_chart_rounded, const Color(0xFF10B981),
                _promedio >= 80 ? 'Óptimo' : 'En mejora')),
        const SizedBox(width: 10),
        Expanded(
            child: _kpi('PENDIENTES', '$_pendientes',
                Icons.warning_amber_rounded, const Color(0xFFEF4444),
                'Requieren acción',
                urgent: _pendientes > 0)),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color,
      String sub, {bool urgent = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: urgent
                ? const Color(0xFFEF4444).withAlpha(80)
                : const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: urgent
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF94A3B8),
                        letterSpacing: 0.5)),
              ),
              Icon(icon,
                  size: 14,
                  color: urgent
                      ? const Color(0xFFEF4444)
                      : color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: urgent
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF0A2540))),
          const SizedBox(height: 2),
          Text(sub,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  color: urgent
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981))),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final total = _auditorias.length;
    final done = _completadas;
    final pct = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF1E3A8A),
                ),
                Center(
                  child: Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A2540))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avance Mensual',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A2540))),
                const SizedBox(height: 4),
                Text(
                    done < total
                        ? 'Estás en buen camino para cumplir tu meta de auditorías de este mes.'
                        : '¡Meta cumplida! Todas las auditorías completadas.',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieCard() {
    final total = _completadas + _pendientes + _conObs;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado de Auditorías',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A2540))),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 32,
                  sections: [
                    if (_completadas > 0)
                      PieChartSectionData(
                          value: _completadas.toDouble(),
                          color: const Color(0xFF10B981),
                          title: '$_completadas',
                          titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                          radius: 50),
                    if (_pendientes > 0)
                      PieChartSectionData(
                          value: _pendientes.toDouble(),
                          color: const Color(0xFFF59E0B),
                          title: '$_pendientes',
                          titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                          radius: 50),
                    if (_conObs > 0)
                      PieChartSectionData(
                          value: _conObs.toDouble(),
                          color: const Color(0xFFEF4444),
                          title: '$_conObs',
                          titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                          radius: 50),
                  ],
                )),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legend('Completadas', const Color(0xFF10B981), _completadas),
                  const SizedBox(height: 8),
                  _legend('Pendientes', const Color(0xFFF59E0B), _pendientes),
                  const SizedBox(height: 8),
                  _legend('Con obs.', const Color(0xFFEF4444), _conObs),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text('$label ($count)',
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildProximasSection() {
    if (_proximas.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Próximas auditorías',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A2540))),
            Text('Ver todas',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF1E3A8A))),
          ],
        ),
        const SizedBox(height: 10),
        ..._proximas.asMap().entries.map((e) {
          final s = e.value;
          final isHigh = s.puntajePromedio > 0 && s.puntajePromedio < 60;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nombre,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A2540))),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(s.region,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8))),
                        ),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHigh
                        ? const Color(0xFFEF4444).withAlpha(26)
                        : const Color(0xFFF59E0B).withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(isHigh ? 'ALTA PRIORIDAD' : 'MEDIA',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isHigh
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B))),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
