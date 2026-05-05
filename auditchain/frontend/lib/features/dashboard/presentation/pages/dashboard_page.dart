import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../mock/mock_data.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/audit_status_badge.dart';

/// Dashboard principal de AuditChain.
///
/// IMPORTANTE: para que las fechas en español funcionen, en `main.dart`
/// se debe llamar:
///
///   await initializeDateFormatting('es', null);
///
/// antes de `runApp(...)` (paquete intl).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _DashboardHeader(),
            SizedBox(height: AppSpacing.xl),
            _KpiRow(),
            SizedBox(height: AppSpacing.lg),
            _ChartsRow(),
            SizedBox(height: AppSpacing.lg),
            _BottomRow(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    String fechaHoy;
    try {
      fechaHoy = DateFormat.MMMMEEEEd('es').format(DateTime.now());
    } catch (_) {
      fechaHoy = DateFormat.MMMMEEEEd().format(DateTime.now());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido, Carlos', style: AppTypography.displayMd),
            const SizedBox(height: 4),
            Text(
              _capitalize(fechaHoy),
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva auditoría'),
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

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FILA KPI
// ─────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final k = MockData.kpis;
    final cumplimiento = k.cumplimiento.toStringAsFixed(1).replaceAll('.', ',');
    final score = k.scorePromedio.toStringAsFixed(1).replaceAll('.', ',');
    final total = NumberFormat.decimalPattern('es').format(k.totalAuditorias);

    final items = <_KpiItem>[
      _KpiItem(label: 'Total auditorías', value: total, delta: '+8,5%', positive: true),
      _KpiItem(label: 'Cumplimiento', value: '$cumplimiento%', delta: '+1,2%', positive: true),
      _KpiItem(label: 'Pendientes', value: '${k.pendientes}', delta: '-3,1%', positive: false),
      _KpiItem(label: 'Auditores activos', value: '${k.auditoresActivos}', delta: '+2', positive: true),
      _KpiItem(label: 'Score promedio', value: score),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: KpiCard(
              label: items[i].label,
              value: items[i].value,
              delta: items[i].delta,
              positive: items[i].positive,
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  final String? delta;
  final bool? positive;
  const _KpiItem({
    required this.label,
    required this.value,
    this.delta,
    this.positive,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FILA GRÁFICOS
// ─────────────────────────────────────────────────────────────────────────────

class _ChartsRow extends StatelessWidget {
  const _ChartsRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(flex: 3, child: _ComplianceByRegionCard()),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _StatusDistributionCard()),
        ],
      ),
    );
  }
}

class _ComplianceByRegionCard extends StatelessWidget {
  const _ComplianceByRegionCard();

  static const _quarterColors = <Color>[
    AppColors.primary600,
    AppColors.primary500,
    AppColors.accent600,
    AppColors.accent500,
  ];
  static const _quarterLabels = ['Q1', 'Q2', 'Q3', 'Q4'];

  @override
  Widget build(BuildContext context) {
    final data = MockData.complianceByRegion;

    return _DashboardCard(
      title: 'Compliance por región',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(_quarterLabels.length, (i) {
              return _LegendDot(
                color: _quarterColors[i],
                label: _quarterLabels[i],
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                minY: 70,
                maxY: 100,
                groupsSpace: 28,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.slate900,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      return BarTooltipItem(
                        '${_quarterLabels[rIdx]}  ${rod.toY.toStringAsFixed(0)}%',
                        AppTypography.bodySm.copyWith(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '${value.toInt()}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.slate500,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[idx]['region'] as String,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.slate700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.slate200,
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (gIdx) {
                  final region = data[gIdx];
                  final values = <double>[
                    (region['q1'] as num).toDouble(),
                    (region['q2'] as num).toDouble(),
                    (region['q3'] as num).toDouble(),
                    (region['q4'] as num).toDouble(),
                  ];
                  return BarChartGroupData(
                    x: gIdx,
                    barsSpace: 4,
                    barRods: List.generate(4, (bIdx) {
                      return BarChartRodData(
                        toY: values[bIdx],
                        color: _quarterColors[bIdx],
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDistributionCard extends StatelessWidget {
  const _StatusDistributionCard();

  static const _completadaColor = Color(0xFF10B981);
  static const _pendienteColor = Color(0xFFF59E0B);
  static const _conObsColor = Color(0xFF38BDF8);
  static const _vencidaColor = Color(0xFF94A3B8);

  Color _colorFor(String estado) {
    switch (estado) {
      case 'completada':
        return _completadaColor;
      case 'pendiente':
        return _pendienteColor;
      case 'con_observaciones':
        return _conObsColor;
      case 'vencida':
        return _vencidaColor;
      default:
        return AppColors.slate400;
    }
  }

  String _labelFor(String estado) {
    switch (estado) {
      case 'completada':
        return 'Completadas';
      case 'pendiente':
        return 'Pendientes';
      case 'con_observaciones':
        return 'Con obs.';
      case 'vencida':
        return 'Vencidas';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = MockData.auditStatusDistribution;
    final entries = dataMap.entries.toList();
    final total = entries.fold<int>(0, (a, b) => a + b.value);

    return _DashboardCard(
      title: 'Distribución de estados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        color: _colorFor(e.key),
                        radius: 36,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern('es').format(total),
                      style: AppTypography.displayLg.copyWith(
                        color: AppColors.slate900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.slate500,
                        letterSpacing: 0.6,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            children: entries.map((e) {
              final pct = total == 0 ? 0.0 : (e.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colorFor(e.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _labelFor(e.key),
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.slate700),
                      ),
                    ),
                    Text(
                      '${NumberFormat.decimalPattern('es').format(e.value)}  ·  ${pct.toStringAsFixed(1)}%',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. FILA INFERIOR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(flex: 2, child: _SucursalesAlertaCard()),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _AuditoriasRecientesCard()),
        ],
      ),
    );
  }
}

class _SucursalesAlertaCard extends StatelessWidget {
  const _SucursalesAlertaCard();

  Color _colorScore(int p) {
    if (p >= 80) return const Color(0xFF10B981);
    if (p >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final sucursales = [...MockData.sucursales]
      ..sort((a, b) => a.puntaje.compareTo(b.puntaje));
    final top3 = sucursales.take(3).toList();

    return _DashboardCard(
      title: 'Sucursales en alerta',
      child: Column(
        children: [
          for (var i = 0; i < top3.length; i++) ...[
            _SucursalAlertRow(
              sucursal: top3[i],
              color: _colorScore(top3[i].puntaje),
            ),
            if (i < top3.length - 1)
              const Divider(height: 1, color: AppColors.slate100),
          ],
        ],
      ),
    );
  }
}

class _SucursalAlertRow extends StatelessWidget {
  final Sucursal sucursal;
  final Color color;
  const _SucursalAlertRow({required this.sucursal, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sucursal.nombre,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sucursal.region,
                  style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
                ),
              ],
            ),
          ),
          Text(
            '${sucursal.puntaje}',
            style: AppTypography.headingMd.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditoriasRecientesCard extends StatelessWidget {
  const _AuditoriasRecientesCard();

  Color _colorScore(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final auditorias = [...MockData.auditorias]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final recent = auditorias.take(8).toList();

    return _DashboardCard(
      title: 'Auditorías recientes',
      padding: EdgeInsets.zero,
      headerPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: const [
                _ColHeader(text: 'ID', flex: 2),
                _ColHeader(text: 'Sucursal', flex: 3),
                _ColHeader(text: 'Auditor', flex: 3),
                _ColHeader(text: 'Fecha', flex: 2),
                _ColHeader(text: 'Score', flex: 1),
                _ColHeader(text: 'Estado', flex: 2),
              ],
            ),
          ),
          for (var i = 0; i < recent.length; i++)
            _AuditoriaRow(
              auditoria: recent[i],
              alt: i.isOdd,
              color: _colorScore(recent[i].puntaje),
            ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _ColHeader({required this.text, required this.flex});

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

class _AuditoriaRow extends StatelessWidget {
  final Auditoria auditoria;
  final bool alt;
  final Color color;
  const _AuditoriaRow({
    required this.auditoria,
    required this.alt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String fechaTxt;
    try {
      fechaTxt = DateFormat.MMMd('es').format(auditoria.fecha);
    } catch (_) {
      fechaTxt = DateFormat.MMMd().format(auditoria.fecha);
    }

    return Container(
      decoration: BoxDecoration(
        color: alt ? const Color(0xFFFAFBFC) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.slate100, width: 1),
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
              auditoria.sucursalNombre,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
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
              _capitalize(fechaTxt),
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

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD CONTENEDOR
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? headerPadding;

  const _DashboardCard({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.headerPadding,
  });

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
            padding: headerPadding ??
                const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            child: Text(
              title,
              style: AppTypography.headingMd.copyWith(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.slate700),
        ),
      ],
    );
  }
}
