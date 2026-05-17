import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class AuditorHistoryScreen extends StatefulWidget {
  const AuditorHistoryScreen({super.key});

  @override
  State<AuditorHistoryScreen> createState() => _AuditorHistoryScreenState();
}

class _AuditorHistoryScreenState extends State<AuditorHistoryScreen> {
  List<Auditoria> _auditorias = [];
  List<Sucursal> _sucursales = [];
  List<Auditor> _auditores = [];
  bool _loading = true;
  String _filtro = 'Todas';
  String _busqueda = '';
  final _searchCtrl = TextEditingController();

  static const _filtros = ['Todas', 'Completadas', 'Pendientes', 'Con obs.'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getAuditorias(),
        ApiService.getSucursales(),
        ApiService.getAuditores(),
      ]);
      setState(() {
        _auditorias = results[0] as List<Auditoria>;
        _sucursales = results[1] as List<Sucursal>;
        _auditores = results[2] as List<Auditor>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  String _sucursal(String id) => _sucursales
      .firstWhere((s) => s.id == id,
          orElse: () => Sucursal(
              id: '', nombre: '—', region: '', estado: '', puntajePromedio: 0))
      .nombre;

  String _auditor(String id) => _auditores
      .firstWhere((a) => a.id == id,
          orElse: () =>
              Auditor(id: '', nombre: '—', email: '', estado: ''))
      .nombre;

  List<Auditoria> get _filtradas {
    var lista = List<Auditoria>.from(_auditorias);
    switch (_filtro) {
      case 'Completadas':
        lista = lista.where((a) => a.estado == 'completada').toList();
        break;
      case 'Pendientes':
        lista = lista.where((a) => a.estado == 'pendiente').toList();
        break;
      case 'Con obs.':
        lista =
            lista.where((a) => a.estado == 'con_observaciones').toList();
        break;
    }
    if (_busqueda.isNotEmpty) {
      lista = lista
          .where((a) => _sucursal(a.sucursalId)
              .toLowerCase()
              .contains(_busqueda.toLowerCase()))
          .toList();
    }
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : NestedScrollView(
              headerSliverBuilder: (ctx, _) => [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Text('Auditorías',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF0A2540),
                          fontWeight: FontWeight.w700,
                          fontSize: 20)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF94A3B8)),
                      onPressed: _cargar,
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(104),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (v) =>
                                  setState(() => _busqueda = v),
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF0A2540)),
                              decoration: InputDecoration(
                                hintText: 'Buscar auditoría...',
                                hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: Color(0xFF94A3B8), size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              children: _filtros.map((f) {
                                final sel = _filtro == f;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(f,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: sel
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.normal)),
                                    selected: sel,
                                    onSelected: (_) =>
                                        setState(() => _filtro = f),
                                    backgroundColor:
                                        const Color(0xFFF1F5F9),
                                    selectedColor: const Color(0xFF1E3A8A),
                                    checkmarkColor: Colors.white,
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: RefreshIndicator(
                onRefresh: _cargar,
                child: _filtradas.isEmpty
                    ? Center(
                        child: Text('Sin resultados',
                            style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8))))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtradas.length,
                        itemBuilder: (ctx, i) => _card(_filtradas[i], i),
                      ),
              ),
            ),
    );
  }

  Widget _card(Auditoria a, int index) {
    Color statusColor;
    String statusLabel;
    Color dateBg = Colors.transparent;
    Color dateColor = const Color(0xFF64748B);

    switch (a.estado) {
      case 'completada':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Completada';
        break;
      case 'con_observaciones':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Vencida';
        dateBg = const Color(0xFFEF4444).withAlpha(20);
        dateColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pendiente';
    }

    final audNum = (5021 + index).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x060F172A), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('#AUD-$audNum',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, color: const Color(0xFF64748B))),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusLabel,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      a.puntaje > 0 ? '${a.puntaje}/100' : '--/100',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: a.puntaje > 0
                              ? (a.puntaje >= 80
                                  ? const Color(0xFF10B981)
                                  : a.puntaje >= 60
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444))
                              : const Color(0xFF94A3B8)),
                    ),
                    Text('Score',
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            color: const Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_sucursal(a.sucursalId),
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A2540))),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: dateBg,
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: dateColor),
                      const SizedBox(width: 4),
                      Text(formatFecha(a.fecha),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: dateColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline,
                    size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(_auditor(a.auditorId),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
