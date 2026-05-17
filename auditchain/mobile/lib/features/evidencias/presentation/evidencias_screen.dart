import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/models.dart';
import '../../../shared/utils/helpers.dart';

class _Evidencia {
  final String tipo;
  final String descripcion;
  final String fecha;
  final IconData icon;
  final Color color;
  _Evidencia({required this.tipo, required this.descripcion,
      required this.fecha, required this.icon, required this.color});
}

class EvidenciasScreen extends StatefulWidget {
  final Auditoria auditoria;
  final String sucursalNombre;

  const EvidenciasScreen({
    super.key,
    required this.auditoria,
    this.sucursalNombre = 'Sucursal',
  });

  @override
  State<EvidenciasScreen> createState() => _EvidenciasScreenState();
}

class _EvidenciasScreenState extends State<EvidenciasScreen> {
  final List<_Evidencia> _evidencias = [
    _Evidencia(tipo: 'Foto', descripcion: 'Estado del área de caja',
        fecha: '09:15', icon: Icons.photo_camera_rounded, color: const Color(0xFF06B6D4)),
    _Evidencia(tipo: 'Foto', descripcion: 'Señalética de seguridad',
        fecha: '09:32', icon: Icons.photo_camera_rounded, color: const Color(0xFF06B6D4)),
    _Evidencia(tipo: 'Documento', descripcion: 'Registro de temperatura',
        fecha: '09:48', icon: Icons.description_rounded, color: const Color(0xFF1E3A8A)),
    _Evidencia(tipo: 'Foto', descripcion: 'Condición de equipamiento',
        fecha: '10:05', icon: Icons.photo_camera_rounded, color: const Color(0xFF06B6D4)),
    _Evidencia(tipo: 'Nota', descripcion: 'Observación: falta señal de salida emergencia',
        fecha: '10:20', icon: Icons.sticky_note_2_rounded, color: const Color(0xFFF59E0B)),
    _Evidencia(tipo: 'Documento', descripcion: 'Planilla de personal',
        fecha: '10:35', icon: Icons.description_rounded, color: const Color(0xFF1E3A8A)),
  ];

  bool _modoGrilla = true;

  void _agregarEvidencia() {
    String tipo = 'Foto';
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2))),
            Text('Agregar evidencia',
                style: GoogleFonts.inter(fontSize: 16,
                    fontWeight: FontWeight.w700, color: const Color(0xFF0A2540))),
            const SizedBox(height: 20),
            Row(children: ['Foto', 'Documento', 'Nota'].map((t) {
              final sel = tipo == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setModal(() => tipo = t),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF1E3A8A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(t,
                          style: GoogleFonts.inter(fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : const Color(0xFF64748B))),
                    ),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0A2540)),
              decoration: InputDecoration(
                hintText: 'Descripción de la evidencia...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                filled: true, fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancelar',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (descCtrl.text.trim().isEmpty) return;
                    final icons = {
                      'Foto': Icons.photo_camera_rounded,
                      'Documento': Icons.description_rounded,
                      'Nota': Icons.sticky_note_2_rounded,
                    };
                    final colors = {
                      'Foto': const Color(0xFF06B6D4),
                      'Documento': const Color(0xFF1E3A8A),
                      'Nota': const Color(0xFFF59E0B),
                    };
                    setState(() => _evidencias.add(_Evidencia(
                      tipo: tipo,
                      descripcion: descCtrl.text.trim(),
                      fecha: 'Ahora',
                      icon: icons[tipo]!,
                      color: colors[tipo]!,
                    )));
                    Navigator.pop(ctx);
                    showSnack(context, 'Evidencia agregada');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Guardar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A2540)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Evidencias',
              style: GoogleFonts.inter(color: const Color(0xFF0A2540),
                  fontWeight: FontWeight.w700, fontSize: 17)),
          Text(widget.sucursalNombre,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
        ]),
        actions: [
          IconButton(
            icon: Icon(
              _modoGrilla ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: const Color(0xFF1E3A8A),
            ),
            onPressed: () => setState(() => _modoGrilla = !_modoGrilla),
          ),
        ],
      ),
      body: Column(children: [
        _buildResumen(),
        Expanded(
          child: _modoGrilla ? _buildGrilla() : _buildLista(),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarEvidencia,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text('Agregar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildResumen() {
    final fotos = _evidencias.where((e) => e.tipo == 'Foto').length;
    final docs = _evidencias.where((e) => e.tipo == 'Documento').length;
    final notas = _evidencias.where((e) => e.tipo == 'Nota').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(children: [
        _chip('${_evidencias.length}', 'Total', const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        _chip('$fotos', 'Fotos', const Color(0xFF06B6D4)),
        const SizedBox(width: 8),
        _chip('$docs', 'Docs', const Color(0xFF1E3A8A).withAlpha(180)),
        const SizedBox(width: 8),
        _chip('$notas', 'Notas', const Color(0xFFF59E0B)),
      ]),
    );
  }

  Widget _chip(String n, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(n,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: color)),
        ]),
      );

  Widget _buildGrilla() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _evidencias.length,
      itemBuilder: (ctx, i) {
        final e = _evidencias[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: e.color.withAlpha(20),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(child: Icon(e.icon, color: e.color, size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF0A2540))),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: e.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(e.tipo,
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: e.color)),
                  ),
                  const Spacer(),
                  Text(e.fecha,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                ]),
              ]),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _evidencias.length,
      itemBuilder: (ctx, i) {
        final e = _evidencias[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: e.color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(e.icon, color: e.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.descripcion,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A2540))),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: e.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(e.tipo,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: e.color)),
                  ),
                  const SizedBox(width: 8),
                  Text(e.fecha,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF94A3B8))),
                ]),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444), size: 20),
              onPressed: () => setState(() => _evidencias.removeAt(i)),
            ),
          ]),
        );
      },
    );
  }
}
