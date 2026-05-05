import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../mock/mock_data.dart';
import '../../../../shared/widgets/audit_status_badge.dart';

/// Listado de auditores de la red.
///
/// Layout:
///   - Header: título "Auditores" + badge conteo + botón "Nuevo auditor".
///   - Card blanca con tabla:
///       Auditor | Email | Región | Asignadas | Estado
///   - Filas alternadas blanco / slate50.
///   - Sin navegación de detalle.
class AuditorsPage extends StatelessWidget {
  const AuditorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auditores = MockData.auditores;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuditorsHeader(count: auditores.length),
            const SizedBox(height: AppSpacing.xl),
            _AuditorsTable(auditores: auditores),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _AuditorsHeader extends StatelessWidget {
  final int count;
  const _AuditorsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    const primary100 = Color(0xFFE0E7FF);
    const primary800 = Color(0xFF1E3A8A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Auditores', style: AppTypography.headingLg),
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
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nuevo auditor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLA
// ─────────────────────────────────────────────────────────────────────────────

const List<int> _kColFlex = <int>[3, 3, 2, 1, 1];

class _AuditorsTable extends StatelessWidget {
  final List<Auditor> auditores;
  const _AuditorsTable({required this.auditores});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TableHeader(),
          for (int i = 0; i < auditores.length; i++)
            _TableRow(
              auditor: auditores[i],
              isAlt: i.isOdd,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER ROW
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTypography.caption.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.slate500,
      letterSpacing: 0.4,
    );

    Widget cell(String label, int flex, {TextAlign align = TextAlign.left}) {
      return Expanded(
        flex: flex,
        child: Text(
          label.toUpperCase(),
          style: headerStyle,
          textAlign: align,
        ),
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
          cell('Auditor', _kColFlex[0]),
          cell('Email', _kColFlex[1]),
          cell('Región', _kColFlex[2]),
          cell('Asignadas', _kColFlex[3]),
          cell('Estado', _kColFlex[4]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA ROW
// ─────────────────────────────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final Auditor auditor;
  final bool isAlt;
  const _TableRow({required this.auditor, required this.isAlt});

  @override
  Widget build(BuildContext context) {
    const primary50 = Color(0xFFEFF2FF);
    const primary700 = Color(0xFF1D4ED8);
    const primary800 = Color(0xFF1E3A8A);

    final asignadas = MockData.auditorias
        .where((au) => au.auditorNombre == auditor.nombre)
        .length;

    final estadoBadge = auditor.estado == 'activo' ? 'completada' : 'vencida';

    return Container(
      decoration: BoxDecoration(
        color: isAlt ? AppColors.slate50 : Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.slate100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: _kColFlex[0],
            child: Row(
              children: [
                _Avatar(
                  initials: _initialsOf(auditor.nombre),
                  bg: primary800,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auditor.nombre,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate900,
                          height: 1.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Auditor de campo',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.slate400,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _kColFlex[1],
            child: Text(
              auditor.email,
              style: AppTypography.monoData(11).copyWith(
                color: primary700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: _kColFlex[2],
            child: Text(
              auditor.region,
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.slate700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: _kColFlex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: primary50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$asignadas',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary800,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _kColFlex[4],
            child: Align(
              alignment: Alignment.centerLeft,
              child: AuditStatusBadge(estado: estadoBadge),
            ),
          ),
        ],
      ),
    );
  }

  static String _initialsOf(String nombre) {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color bg;
  const _Avatar({required this.initials, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppTypography.bodySm.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}
