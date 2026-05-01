import 'package:flutter/material.dart';
import '../models/models.dart';

// ─── HELPERS ──────────────────────────────────────────────────────────────────

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? Colors.red[700] : Colors.green[700],
    duration: const Duration(seconds: 3),
  ));
}

Future<bool> confirmar(BuildContext context, String msg) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar'),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar', style: TextStyle(color: Colors.red))),
      ],
    ),
  ) ?? false;
}

Color _puntajeColor(int p) => p >= 80 ? Colors.green : p >= 60 ? Colors.orange : Colors.red;
Color _estadoColor(String e) {
  switch (e) {
    case 'activo': case 'completada': return Colors.green;
    case 'con_observaciones': return Colors.red;
    default: return Colors.grey;
  }
}

// ─── PAGE LAYOUT ──────────────────────────────────────────────────────────────

class PageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNew;
  final Widget child;

  const PageLayout({super.key, required this.title, required this.subtitle, required this.onNew, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

// ─── STATS ────────────────────────────────────────────────────────────────────

class StatsRow extends StatelessWidget {
  final List<StatCard> stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: s))).toList(),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  const StatCard({super.key, required this.label, required this.value, required this.sub, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ─── TABLE CARD ───────────────────────────────────────────────────────────────

class TableCard extends StatelessWidget {
  final int count;
  final bool loading;
  final List<String> headers;
  final List<List<String>> rows;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final int? puntajeCol;
  final int? estadoCol;

  const TableCard({
    super.key, required this.count, required this.loading,
    required this.headers, required this.rows,
    required this.onEdit, required this.onDelete,
    this.puntajeCol, this.estadoCol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('REGISTROS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                Text('$count registros', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (loading)
            const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
          else if (rows.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Text('No hay registros aún', style: TextStyle(color: Colors.grey)))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
                columns: headers.map((h) => DataColumn(
                  label: Text(h, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                )).toList(),
                rows: List.generate(rows.length, (i) {
                  final row = rows[i];
                  return DataRow(cells: List.generate(row.length, (j) {
                    if (j == row.length - 1) {
                      return DataCell(Row(children: [
                        IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => onEdit(i), color: Colors.grey),
                        IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () => onDelete(i), color: Colors.red[300]),
                      ]));
                    }
                    if (j == estadoCol) {
                      return DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _estadoColor(row[j]).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(row[j].replaceAll('_', ' '), style: TextStyle(fontSize: 12, color: _estadoColor(row[j]), fontWeight: FontWeight.w500)),
                      ));
                    }
                    if (j == puntajeCol) {
                      final p = int.tryParse(row[j].replaceAll('%', '')) ?? 0;
                      return DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _puntajeColor(p).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(row[j], style: TextStyle(fontSize: 12, color: _puntajeColor(p), fontWeight: FontWeight.bold)),
                      ));
                    }
                    return DataCell(Text(row[j], style: TextStyle(
                      fontSize: 13,
                      fontWeight: j == 0 ? FontWeight.w600 : FontWeight.normal,
                      color: j == 0 ? const Color(0xFF1A1A2E) : const Color(0xFF555555),
                    )));
                  }));
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── FORM DIALOG ─────────────────────────────────────────────────────────────

class FormDialog extends StatelessWidget {
  final String title;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> fields;

  const FormDialog({super.key, required this.title, required this.saving, required this.onSave, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: saving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Guardar'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── FORM FIELDS ──────────────────────────────────────────────────────────────

class FormField2 extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final int maxLines;
  final Function(String)? onChanged;

  const FormField2({super.key, required this.label, required this.controller, this.obscure = false, this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555), letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00B4D8))),
          ),
        ),
      ]),
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String>? labels;
  final Function(String?) onChanged;

  const DropdownField({super.key, required this.label, required this.value, required this.items, this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555), letterSpacing: 0.5)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.isNotEmpty ? items[0] : null,
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          ),
          items: List.generate(items.length, (i) => DropdownMenuItem(
            value: items[i],
            child: Text(labels != null ? labels![i] : items[i], overflow: TextOverflow.ellipsis),
          )),
          onChanged: onChanged,
        ),
      ]),
    );
  }
}
