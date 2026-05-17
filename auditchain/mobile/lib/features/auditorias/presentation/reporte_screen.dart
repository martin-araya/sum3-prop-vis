import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/models.dart';
import '../../../shared/utils/helpers.dart';
import '../../evidencias/presentation/evidencias_screen.dart';

class ReporteScreen extends StatelessWidget {
  final Auditoria auditoria;
  final String sucursalNombre;
  final String auditorNombre;

  const ReporteScreen({
    super.key,
    required this.auditoria,
    this.sucursalNombre = 'Sucursal',
    this.auditorNombre = 'Auditor',
  });

  Color get _scoreColor {
    if (auditoria.puntaje >= 80) return const Color(0xFF10B981);
    if (auditoria.puntaje >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _estadoLabel => switch (auditoria.estado) {
        'completada' => 'Completada',
        'pendiente' => 'Pendiente',
        'con_observaciones' => 'Con observaciones',
        _ => auditoria.estado,
      };

  Color get _estadoColor => switch (auditoria.estado) {
        'completada' => const Color(0xFF10B981),
        'pendiente' => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildScoreCard(),
                const SizedBox(height: 12),
                _buildInfoCard(),
                const SizedBox(height: 12),
                _buildChecklistCard(),
                if (auditoria.notas != null && auditoria.notas!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildNotasCard(),
                ],
                const SizedBox(height: 12),
                _buildAcciones(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF1E3A8A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
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
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _estadoColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _estadoColor.withAlpha(80)),
                        ),
                        child: Text(_estadoLabel,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _estadoColor)),
                      ),
                      const Spacer(),
                      Text('#AUD-${auditoria.id.hashCode.abs() % 9000 + 1000}',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 11, color: Colors.white54)),
                    ]),
                    const SizedBox(height: 8),
                    Text(sucursalNombre,
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]),
            ),
          ),
        ),
        title: Text(sucursalNombre,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [
        SizedBox(
          width: 80, height: 80,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(
              value: auditoria.puntaje / 100,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              color: _scoreColor,
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${auditoria.puntaje}',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor)),
              Text('/ 100',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF94A3B8))),
            ]),
          ]),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Puntaje final',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(
                auditoria.puntaje >= 80
                    ? 'Excelente cumplimiento'
                    : auditoria.puntaje >= 60
                        ? 'Cumplimiento aceptable'
                        : 'Requiere mejoras',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: auditoria.puntaje / 100,
                backgroundColor: const Color(0xFFE2E8F0),
                color: _scoreColor,
                minHeight: 6,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        _infoRow(Icons.store_rounded, 'Sucursal', sucursalNombre),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        _infoRow(Icons.person_outline_rounded, 'Auditor', auditorNombre),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        _infoRow(Icons.calendar_today_outlined, 'Fecha',
            formatFecha(auditoria.fecha)),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        _infoRow(Icons.flag_outlined, 'Estado', _estadoLabel,
            valueColor: _estadoColor),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(children: [
      Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      const SizedBox(width: 12),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 13, color: const Color(0xFF64748B))),
      const Spacer(),
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0A2540))),
    ]);
  }

  Widget _buildChecklistCard() {
    final items = [
      ('Higiene y limpieza', true),
      ('Seguridad operacional', true),
      ('Documentación al día', auditoria.puntaje >= 50),
      ('Equipamiento correcto', true),
      ('Atención al cliente', auditoria.puntaje >= 60),
      ('Cumplimiento normativo', auditoria.puntaje >= 70),
      ('Control de inventario', auditoria.puntaje >= 80),
      ('Señalética visible', auditoria.puntaje >= 90),
    ];

    final aprobados = items.where((i) => i.$2).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Checklist',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A2540))),
          const Spacer(),
          Text('$aprobados/${items.length}',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A))),
        ]),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(
                  item.$2
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color: item.$2
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 10),
                Text(item.$1,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: item.$2
                            ? const Color(0xFF0A2540)
                            : const Color(0xFF94A3B8),
                        decoration: item.$2 ? null : TextDecoration.lineThrough)),
              ]),
            )),
      ]),
    );
  }

  Widget _buildNotasCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.sticky_note_2_rounded,
              size: 16, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text('Observaciones',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E))),
        ]),
        const SizedBox(height: 8),
        Text(auditoria.notas!,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF78350F),
                height: 1.5)),
      ]),
    );
  }

  Widget _buildAcciones(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvidenciasScreen(
                auditoria: auditoria,
                sucursalNombre: sucursalNombre,
              ),
            ),
          ),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text('Ver evidencias',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => showSnack(context, 'Exportando reporte PDF...'),
          icon: const Icon(Icons.picture_as_pdf_outlined,
              color: Color(0xFF1E3A8A)),
          label: Text('Exportar PDF',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A8A))),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1E3A8A)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }
}
