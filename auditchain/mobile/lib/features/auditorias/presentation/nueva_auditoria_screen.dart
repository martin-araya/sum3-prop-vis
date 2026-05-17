import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_routes.dart';
import '../../../shared/models/models.dart';
import '../../../shared/utils/helpers.dart';

class NuevaAuditoriaScreen extends StatefulWidget {
  const NuevaAuditoriaScreen({super.key});

  @override
  State<NuevaAuditoriaScreen> createState() => _NuevaAuditoriaScreenState();
}

class _NuevaAuditoriaScreenState extends State<NuevaAuditoriaScreen> {
  int _paso = 0;
  bool _loading = true;
  bool _enviando = false;

  List<Sucursal> _sucursales = [];
  List<Auditor> _auditores = [];

  Sucursal? _sucursal;
  Auditor? _auditor;
  DateTime _fecha = DateTime.now();
  final _notasCtrl = TextEditingController();

  final Map<String, bool> _checklist = {
    'Higiene y limpieza': false,
    'Seguridad operacional': false,
    'Documentación al día': false,
    'Equipamiento correcto': false,
    'Atención al cliente': false,
    'Cumplimiento normativo': false,
    'Control de inventario': false,
    'Señalética visible': false,
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final r = await Future.wait([fetchSucursales(), fetchAuditores()]);
      setState(() {
        _sucursales = r[0] as List<Sucursal>;
        _auditores = r[1] as List<Auditor>;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _fecha = d);
  }

  int get _puntajeChecklist {
    final total = _checklist.length;
    final ok = _checklist.values.where((v) => v).length;
    return total == 0 ? 0 : (ok * 100 ~/ total);
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      final user = await AuthClient.getUser();
      await DioClient.post(ApiRoutes.auditorias, {
        'sucursal_id': _sucursal!.id,
        'auditor_id': _auditor?.id ?? user?['id'],
        'fecha': _fecha.toIso8601String().split('T').first,
        'puntaje': _puntajeChecklist,
        'estado': _puntajeChecklist >= 70 ? 'completada' : 'con_observaciones',
        'notas': _notasCtrl.text.trim(),
      });
      if (mounted) {
        showSnack(context, 'Auditoría registrada exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Error al guardar: $e', error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0A2540)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nueva Auditoría',
            style: GoogleFonts.inter(
                color: const Color(0xFF0A2540),
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('Paso ${_paso + 1} de 4',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF94A3B8))),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : Column(children: [
              _buildProgreso(),
              Expanded(child: _buildPaso()),
              _buildBotones(),
            ]),
    );
  }

  Widget _buildProgreso() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(4, (i) {
          final done = i < _paso;
          final current = i == _paso;
          return Expanded(
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? const Color(0xFF10B981)
                      : current
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFE2E8F0),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: current
                                  ? Colors.white
                                  : const Color(0xFF94A3B8))),
                ),
              ),
              if (i < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ]),
          );
        }),
      ),
    );
  }

  Widget _buildPaso() {
    switch (_paso) {
      case 0:
        return _paso1();
      case 1:
        return _paso2();
      case 2:
        return _paso3();
      case 3:
        return _paso4();
      default:
        return const SizedBox();
    }
  }

  Widget _paso1() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccion('Selecciona la sucursal a auditar'),
        ..._sucursales.map((s) {
          final sel = _sucursal?.id == s.id;
          return GestureDetector(
            onTap: () => setState(() => _sucursal = s),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF1E3A8A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel
                        ? Colors.white.withAlpha(30)
                        : const Color(0xFFF1F5F9),
                  ),
                  child: Icon(Icons.store_rounded,
                      color: sel ? Colors.white : const Color(0xFF1E3A8A),
                      size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.nombre,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : const Color(0xFF0A2540))),
                        Text(s.region,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: sel
                                    ? Colors.white.withAlpha(180)
                                    : const Color(0xFF64748B))),
                      ]),
                ),
                if (sel)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
              ]),
            ),
          );
        }),
      ],
    );
  }

  Widget _paso2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccion('Fecha de auditoría'),
        GestureDetector(
          onTap: _pickFecha,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month_rounded,
                  color: Color(0xFF1E3A8A), size: 22),
              const SizedBox(width: 12),
              Text(formatFecha(_fecha.toIso8601String().split('T').first),
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A2540))),
              const Spacer(),
              const Icon(Icons.edit_calendar_outlined,
                  color: Color(0xFF94A3B8), size: 18),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        _seccion('Asignar auditor'),
        ..._auditores.map((a) {
          final sel = _auditor?.id == a.id;
          return GestureDetector(
            onTap: () => setState(() => _auditor = a),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF1E3A8A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: sel
                      ? Colors.white.withAlpha(40)
                      : const Color(0xFF1E3A8A).withAlpha(26),
                  child: Text(
                      a.nombre.isNotEmpty ? a.nombre[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : const Color(0xFF1E3A8A))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.nombre,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF0A2540))),
                        Text(a.email,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: sel
                                    ? Colors.white.withAlpha(180)
                                    : const Color(0xFF94A3B8))),
                      ]),
                ),
                if (sel)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
              ]),
            ),
          );
        }),
      ],
    );
  }

  Widget _paso3() {
    final aprobados = _checklist.values.where((v) => v).length;
    final total = _checklist.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccion('Checklist de cumplimiento'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withAlpha(13),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color(0xFF1E3A8A).withAlpha(40)),
          ),
          child: Row(children: [
            Text('$aprobados / $total ítems',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A))),
            const Spacer(),
            Text('Puntaje: $_puntajeChecklist/100',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _puntajeChecklist >= 70
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444))),
          ]),
        ),
        const SizedBox(height: 12),
        ..._checklist.keys.map((item) => CheckboxListTile(
              value: _checklist[item],
              onChanged: (v) =>
                  setState(() => _checklist[item] = v ?? false),
              title: Text(item,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF0A2540))),
              activeColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tileColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            )),
      ],
    );
  }

  Widget _paso4() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccion('Resumen de auditoría'),
        _resumenItem(Icons.store_rounded, 'Sucursal',
            _sucursal?.nombre ?? '—'),
        _resumenItem(Icons.person_outline_rounded, 'Auditor',
            _auditor?.nombre ?? 'Sin asignar'),
        _resumenItem(Icons.calendar_today_outlined, 'Fecha',
            formatFecha(_fecha.toIso8601String().split('T').first)),
        _resumenItem(Icons.check_circle_outline_rounded, 'Puntaje',
            '$_puntajeChecklist / 100 pts'),
        const SizedBox(height: 20),
        _seccion('Observaciones (opcional)'),
        TextField(
          controller: _notasCtrl,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0A2540)),
          decoration: InputDecoration(
            hintText: 'Describe hallazgos, incidencias o recomendaciones...',
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E3A8A), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _resumenItem(IconData icon, String label, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 12),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF64748B))),
        const Spacer(),
        Text(valor,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A2540))),
      ]),
    );
  }

  Widget _seccion(String titulo) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(titulo,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.3)),
      );

  Widget _buildBotones() {
    final puedeAvanzar = switch (_paso) {
      0 => _sucursal != null,
      1 => true,
      2 => true,
      3 => true,
      _ => false,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(children: [
        if (_paso > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _paso--),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  Text('Atrás', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
        if (_paso > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: puedeAvanzar
                ? () {
                    if (_paso < 3) {
                      setState(() => _paso++);
                    } else {
                      _enviar();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _enviando
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(
                    _paso < 3 ? 'Continuar' : 'Guardar auditoría',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}
