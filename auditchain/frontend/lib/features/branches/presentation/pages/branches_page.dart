import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../mock/mock_data.dart';
import '../../../../shared/widgets/audit_status_badge.dart';

/// Listado de sucursales auditables.
///
/// Layout:
///   - Header: título + badge conteo + botón "Nueva sucursal".
///   - Grid responsivo de tarjetas (3 / 2 / 1 columnas según ancho).
///
/// Cada tarjeta navega a `/sucursales/:id` al hacer tap.
class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sucursales = MockData.sucursales;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BranchesHeader(count: sucursales.length),
            const SizedBox(height: AppSpacing.xl),
            _BranchesGrid(sucursales: sucursales),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesHeader extends StatelessWidget {
  final int count;
  const _BranchesHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    const primary100 = Color(0xFFE0E7FF);
    const primary800 = Color(0xFF1E3A8A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Sucursales', style: AppTypography.headingLg),
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
          label: const Text('Nueva sucursal'),
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
// GRID
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesGrid extends StatelessWidget {
  final List<Sucursal> sucursales;
  const _BranchesGrid({required this.sucursales});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 1100 ? 3 : (w > 700 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sucursales.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: 260,
          ),
          itemBuilder: (context, index) {
            return _BranchCard(sucursal: sucursales[index]);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  final Sucursal sucursal;
  const _BranchCard({required this.sucursal});

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(sucursal.puntaje);

    final esActiva = sucursal.estado == 'activa' || sucursal.estado == 'activo';
    final estadoBadge = esActiva ? 'completada' : 'vencida';

    String fechaTxt;
    try {
      fechaTxt = DateFormat.yMMMd('es').format(sucursal.ultimaAuditoria);
    } catch (_) {
      fechaTxt = DateFormat.yMMMd().format(sucursal.ultimaAuditoria);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go('/sucursales/${sucursal.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      sucursal.nombre,
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AuditStatusBadge(estado: estadoBadge),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sucursal.region,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.slate100),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${sucursal.puntaje}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: color,
                        height: 1,
                        fontFamily: AppTypography.headingLg.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score promedio',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Última auditoría: $fechaTxt',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.slate100, width: 1),
                  ),
                ),
                child: Text(
                  'Ver detalles →',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
