import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../mock/mock_data.dart';
import '../../../../shared/widgets/audit_status_badge.dart';

/// Detalle de una sucursal: nombre, región, score circular y tabla de
/// auditorías asociadas.
class BranchDetailPage extends StatelessWidget {
  final String sucursalId;
  const BranchDetailPage({super.key, required this.sucursalId});

  @override
  Widget build(BuildContext context) {
    final sucursal = MockData.sucursalById(sucursalId);

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go('/sucursales'),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Volver'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate700,
                  textStyle: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (sucursal == null)
              _NotFound(id: sucursalId)
            else
              _BranchDetailBody(sucursal: sucursal),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────

class _BranchDetailBody extends StatelessWidget {
  final Sucursal sucursal;
  const _BranchDetailBody({required this.sucursal});

  @override
  Widget build(BuildContext context) {
    final auditorias = MockData.auditoriasBySucursal(sucursal.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(sucursal: sucursal),
        const SizedBox(height: AppSpacing.xl),
        _AuditTable(auditorias: auditorias),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO con score circular
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Sucursal sucursal;
  const _HeroCard({required this.sucursal});

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(sucursal.puntaje);
    final esActiva =
        sucursal.estado == 'activa' || sucursal.estado == 'activo';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      sucursal.id,
                      style: AppTypography.monoData(12).copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AuditStatusBadge(
                      estado: esActiva ? 'completada' : 'vencida',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sucursal.nombre,
                  style: AppTypography.displayMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.slate500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sucursal.region,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _MetaRow(
                  label: 'Auditor asignado',
                  value: sucursal.auditorAsignado,
                ),
                const SizedBox(height: AppSpacing.xs),
                _MetaRow(
                  label: 'Última auditoría',
                  value: _formatDate(sucursal.ultimaAuditoria),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          _ScoreRing(score: sucursal.puntaje, color: color),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    try {
      return DateFormat.yMMMd('es').format(d);
    } catch (_) {
      return DateFormat.yMMMd().format(d);
    }
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.slate900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE CIRCULAR (CustomPaint)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RingPainter(progress: score / 100.0, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                  fontFamily: AppTypography.headingLg.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'de 100',
                style: AppTypography.caption.copyWith(
                  color: AppColors.slate500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final track = Paint()
      ..color = AppColors.slate100
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLA DE AUDITORÍAS
// ─────────────────────────────────────────────────────────────────────────────

class _AuditTable extends StatelessWidget {
  final List<Auditoria> auditorias;
  const _AuditTable({required this.auditorias});

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              'Historial de auditorías',
              style: AppTypography.headingMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: const [
                _Col(text: 'ID', flex: 2),
                _Col(text: 'Auditor', flex: 3),
                _Col(text: 'Fecha', flex: 2),
                _Col(text: 'Score', flex: 1),
                _Col(text: 'Estado', flex: 2),
              ],
            ),
          ),
          if (auditorias.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'Esta sucursal aún no tiene auditorías registradas.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.slate500,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < auditorias.length; i++)
              _AuditRow(
                auditoria: auditorias[i],
                alt: i.isOdd,
                color: _scoreColor(auditorias[i].puntaje),
                last: i == auditorias.length - 1,
              ),
        ],
      ),
    );
  }
}

class _Col extends StatelessWidget {
  final String text;
  final int flex;
  const _Col({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.slate500,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final Auditoria auditoria;
  final bool alt;
  final bool last;
  final Color color;
  const _AuditRow({
    required this.auditoria,
    required this.alt,
    required this.last,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String fechaTxt;
    try {
      fechaTxt = DateFormat.yMMMd('es').format(auditoria.fecha);
    } catch (_) {
      fechaTxt = DateFormat.yMMMd().format(auditoria.fecha);
    }

    return Container(
      decoration: BoxDecoration(
        color: alt ? const Color(0xFFFAFBFC) : Colors.white,
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.slate100, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              auditoria.id,
              style: AppTypography.monoData(11).copyWith(
                color: AppColors.primary600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              auditoria.auditorNombre,
              style: AppTypography.bodySm.copyWith(color: AppColors.slate700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fechaTxt,
              style: AppTypography.bodySm.copyWith(color: AppColors.slate700),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              auditoria.puntaje == 0 ? '—' : '${auditoria.puntaje}',
              style: AppTypography.bodySm.copyWith(
                color: auditoria.puntaje == 0 ? AppColors.slate400 : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AuditStatusBadge(estado: auditoria.estado),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK
// ─────────────────────────────────────────────────────────────────────────────

class _NotFound extends StatelessWidget {
  final String id;
  const _NotFound({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 32,
              color: AppColors.slate400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sucursal no encontrada',
              style: AppTypography.headingMd,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No existe ninguna sucursal con id "$id".',
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
