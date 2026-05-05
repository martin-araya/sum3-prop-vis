import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../mock/mock_data.dart';
import '../../../../shared/widgets/audit_status_badge.dart';

/// Listado de auditorías con filtros por estado.
///
/// Layout:
///   - Header: título + badge con conteo filtrado.
///   - Barra horizontal de FilterChips (estado).
///   - Tabla en card blanca con filas alternadas y columnas:
///     ID | Sucursal | Auditor | Fecha | Score | Estado | —
///   - Empty state si el filtro no devuelve resultados.
class AuditsPage extends StatefulWidget {
  const AuditsPage({super.key});

  @override
  State<AuditsPage> createState() => _AuditsPageState();
}

class _AuditsPageState extends State<AuditsPage> {
  // 'todas' | 'pendiente' | 'completada' | 'con_observaciones' | 'vencida'
  String _filtroEstado = 'todas';

  List<Auditoria> get _auditoriasFiltered => _filtroEstado == 'todas'
      ? MockData.auditorias
      : MockData.auditorias
          .where((a) => a.estado == _filtroEstado)
          .toList();

  void _setFiltro(String value) {
    setState(() => _filtroEstado = value);
  }

  @override
  Widget build(BuildContext context) {
    final auditorias = _auditoriasFiltered;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuditsHeader(count: auditorias.length),
            const SizedBox(height: AppSpacing.lg),
            _FilterBar(
              selected: _filtroEstado,
              onChanged: _setFiltro,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (auditorias.isEmpty)
              const _EmptyState()
            else
              _AuditsTable(auditorias: auditorias),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _AuditsHeader extends StatelessWidget {
  final int count;
  const _AuditsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    const primary100 = Color(0xFFE0E7FF);
    const primary800 = Color(0xFF1E3A8A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Auditorías', style: AppTypography.headingLg),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primary100,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: AppTypography.bodySm.copyWith(
              color: primary800,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  static const List<_FilterOption> _options = [
    _FilterOption('todas', 'Todas'),
    _FilterOption('pendiente', 'Pendientes'),
    _FilterOption('completada', 'Completadas'),
    _FilterOption('con_observaciones', 'Con observaciones'),
    _FilterOption('vencida', 'Vencidas'),
  ];

  @override
  Widget build(BuildContext context) {
    const primary800 = Color(0xFF1E3A8A);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _Chip(
              label: _options[i].label,
              isSelected: selected == _options[i].value,
              selectedColor: primary800,
              onTap: () => onChanged(_options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterOption {
  final String value;
  final String label;
  const _FilterOption(this.value, this.label);
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? selectedColor : Colors.white;
    final fg = isSelected ? Colors.white : AppColors.slate700;
    final borderColor = isSelected ? selectedColor : AppColors.slate200;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: fg,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLA
// ─────────────────────────────────────────────────────────────────────────────

class _AuditsTable extends StatelessWidget {
  final List<Auditoria> auditorias;
  const _AuditsTable({required this.auditorias});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeaderRow(),
            for (int i = 0; i < auditorias.length; i++)
              _AuditRow(
                auditoria: auditorias[i],
                isOdd: i.isOdd,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Flex por columna: ID | Sucursal | Auditor | Fecha | Score | Estado | More
const List<int> _kAuditColFlex = <int>[2, 4, 3, 2, 1, 2, 1];

// ─── Header ──────────────────────────────────────────────────────────────────

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTypography.caption.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.slate600,
      letterSpacing: 0.4,
    );

    Widget cell(String label, int flex,
        {TextAlign align = TextAlign.left}) {
      return Expanded(
        flex: flex,
        child: Text(label.toUpperCase(), style: headerStyle, textAlign: align),
      );
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          cell('ID',       _kAuditColFlex[0]),
          cell('Sucursal', _kAuditColFlex[1]),
          cell('Auditor',  _kAuditColFlex[2]),
          cell('Fecha',    _kAuditColFlex[3]),
          cell('Score',    _kAuditColFlex[4], align: TextAlign.center),
          cell('Estado',   _kAuditColFlex[5]),
          cell('',         _kAuditColFlex[6]),
        ],
      ),
    );
  }
}

// ─── Fila ────────────────────────────────────────────────────────────────────

class _AuditRow extends StatelessWidget {
  final Auditoria auditoria;
  final bool isOdd;
  const _AuditRow({required this.auditoria, required this.isOdd});

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _formatFecha(DateTime fecha) {
    try {
      return DateFormat.MMMd('es').format(fecha);
    } catch (_) {
      return DateFormat.MMMd().format(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isOdd ? const Color(0xFFFAFAFA) : Colors.white;
    final score = auditoria.puntaje;
    final hasScore = score > 0;
    final scoreColor = _scoreColor(score);
    final fechaTxt = _formatFecha(auditoria.fecha);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: const Border(
          top: BorderSide(color: AppColors.slate100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ID
          Expanded(
            flex: _kAuditColFlex[0],
            child: Text(
              auditoria.id,
              style: AppTypography.monoData(12).copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Sucursal
          Expanded(
            flex: _kAuditColFlex[1],
            child: Text(
              auditoria.sucursalNombre,
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.slate800,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Auditor
          Expanded(
            flex: _kAuditColFlex[2],
            child: Text(
              auditoria.auditorNombre,
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.slate700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Fecha
          Expanded(
            flex: _kAuditColFlex[3],
            child: Text(
              fechaTxt,
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.slate500,
              ),
            ),
          ),
          // Score
          Expanded(
            flex: _kAuditColFlex[4],
            child: Align(
              alignment: Alignment.center,
              child: hasScore
                  ? Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$score',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    )
                  : Text(
                      '—',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13,
                        color: AppColors.slate400,
                      ),
                    ),
            ),
          ),
          // Estado
          Expanded(
            flex: _kAuditColFlex[5],
            child: Align(
              alignment: Alignment.centerLeft,
              child: AuditStatusBadge(estado: auditoria.estado),
            ),
          ),
          // Más opciones
          Expanded(
            flex: _kAuditColFlex[6],
            child: const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.slate400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin auditorías para este filtro',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.slate500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
