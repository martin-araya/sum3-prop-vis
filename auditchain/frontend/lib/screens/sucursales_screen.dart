import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});
  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
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
      final data = await ApiService.getSucursales();
      setState(() { _sucursales = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _abrirFormulario([Sucursal? s]) {
    showDialog(context: context, builder: (_) => SucursalForm(sucursal: s, onSaved: _cargar));
  }

  Future<void> _eliminar(String id) async {
    final ok = await confirmar(context, '¿Eliminar esta sucursal?');
    if (!ok) return;
    try {
      await ApiService.deleteSucursal(id);
      showSnack(context, 'Sucursal eliminada');
      _cargar();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activas = _sucursales.where((s) => s.estado == 'activo').length;
    final prom = _sucursales.isEmpty ? 0.0 : _sucursales.map((s) => s.puntajePromedio).reduce((a, b) => a + b) / _sucursales.length;

    return PageLayout(
      title: 'Sucursales',
      subtitle: 'Gestión de locales comerciales',
      onNew: () => _abrirFormulario(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsRow(stats: [
            StatCard(label: 'Total', value: '${_sucursales.length}', sub: 'sucursales registradas'),
            StatCard(label: 'Activas', value: '$activas', sub: 'operativas', valueColor: Colors.green),
            StatCard(label: 'Puntaje Prom.', value: '${prom.toStringAsFixed(0)}%', sub: 'cumplimiento promedio', valueColor: const Color(0xFF00B4D8)),
          ]),
          const SizedBox(height: 20),
          TableCard(
            count: _sucursales.length,
            loading: _loading,
            headers: const ['Nombre', 'Región', 'Dirección', 'Estado', 'Puntaje', 'Acciones'],
            rows: _sucursales.map((s) => [
              s.nombre,
              s.region,
              s.direccion ?? '—',
              s.estado,
              '${s.puntajePromedio.toStringAsFixed(0)}%',
              s.id,
            ]).toList(),
            onEdit: (i) => _abrirFormulario(_sucursales[i]),
            onDelete: (i) => _eliminar(_sucursales[i].id),
            puntajeCol: 4,
            estadoCol: 3,
          ),
        ],
      ),
    );
  }
}

class SucursalForm extends StatefulWidget {
  final Sucursal? sucursal;
  final VoidCallback onSaved;
  const SucursalForm({super.key, this.sucursal, required this.onSaved});
  @override
  State<SucursalForm> createState() => _SucursalFormState();
}

class _SucursalFormState extends State<SucursalForm> {
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  String _region = 'Región Metropolitana';
  String _estado = 'activo';
  bool _saving = false;

  final _regiones = ['Región Metropolitana','Región de Valparaíso','Región del Biobío','Región de La Araucanía','Región de Los Lagos','Región de Antofagasta','Región de Coquimbo'];

  @override
  void initState() {
    super.initState();
    if (widget.sucursal != null) {
      _nombre.text = widget.sucursal!.nombre;
      _direccion.text = widget.sucursal!.direccion ?? '';
      _region = widget.sucursal!.region;
      _estado = widget.sucursal!.estado;
    }
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    try {
      final data = {'nombre': _nombre.text, 'region': _region, 'direccion': _direccion.text.isEmpty ? null : _direccion.text, 'estado': _estado};
      if (widget.sucursal != null) {
        await ApiService.updateSucursal(widget.sucursal!.id, data);
      } else {
        await ApiService.createSucursal(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
      if (mounted) showSnack(context, widget.sucursal != null ? 'Sucursal actualizada' : 'Sucursal creada');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => FormDialog(
    title: widget.sucursal != null ? 'Editar Sucursal' : 'Nueva Sucursal',
    saving: _saving,
    onSave: _guardar,
    fields: [
      FormField2(label: 'Nombre *', controller: _nombre),
      DropdownField(label: 'Región *', value: _region, items: _regiones, onChanged: (v) => setState(() => _region = v!)),
      FormField2(label: 'Dirección', controller: _direccion),
      DropdownField(label: 'Estado', value: _estado, items: const ['activo', 'inactivo'], onChanged: (v) => setState(() => _estado = v!)),
    ],
  );
}
