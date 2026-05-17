import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/shared/widgets/audit_status_badge.dart';
import '../../data/datasources/auditores_remote_datasource.dart';
import '../../data/models/auditor_dto.dart';

/// Listado de auditores de la red.
///
/// Layout:
///   - Header: título "Auditores" + badge conteo + botón "Nuevo auditor".
///   - Card blanca con tabla:
///       Auditor | Email | Región | Estado
///   - Filas alternadas blanco / slate50.
class AuditorsPage extends StatefulWidget {
  const AuditorsPage({super.key});

  @override
  State<AuditorsPage> createState() => _AuditorsPageState();
}

class _AuditorsPageState extends State<AuditorsPage> {
  final AuditoresRemoteDatasource _datasource = AuditoresRemoteDatasource();

  List<AuditorDto> _auditores = <AuditorDto>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuditores();
  }

  Future<void> _loadAuditores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _datasource.getAll();
      if (mounted) {
        setState(() {
          _auditores = page.items;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40, color: AppColors.slate400),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadAuditores,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _AuditorsHeader(
            count: _auditores.length,
          ),
          const SizedBox(height: AppSpacing.xl),
          _AuditorsTable(auditores: _auditores),
        ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Auditores', style: AppTypography.headingLg),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.primary800,
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

const List<int> _kColFlex = <int>[3, 3, 2, 1];

class _AuditorsTable extends StatelessWidget {
  final List<AuditorDto> auditores;
  const _AuditorsTable({required this.auditores});

  @override
  Widget build(BuildContext context) {
    if (auditores.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200, width: 1),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: Text(
            'No hay auditores registrados.',
            style: AppTypography.bodySm.copyWith(color: AppColors.slate500),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _TableHeader(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auditores.length,
            itemBuilder: (BuildContext context, int index) => _TableRow(
              auditor: auditores[index],
              isAlt: index.isOdd,
            ),
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
    final TextStyle headerStyle = AppTypography.caption.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.slate500,
      letterSpacing: 0.4,
    );

    Widget cell(String label, int flex) => Expanded(
          flex: flex,
          child: Text(label.toUpperCase(), style: headerStyle),
        );

    return Container(
      color: AppColors.slate50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          cell('Auditor', _kColFlex[0]),
          cell('Email', _kColFlex[1]),
          cell('Región', _kColFlex[2]),
          cell('Estado', _kColFlex[3]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA ROW
// ─────────────────────────────────────────────────────────────────────────────

class _TableRow extends StatelessWidget {
  final AuditorDto auditor;
  final bool isAlt;
  const _TableRow({required this.auditor, required this.isAlt});

  static String _initialsOf(String nombre) {
    final List<String> parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {

    final String estadoBadge = auditor.activo ? 'completada' : 'vencida';

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
        children: <Widget>[
          // Auditor: avatar + nombre + rol
          Expanded(
            flex: _kColFlex[0],
            child: Row(
              children: <Widget>[
                _Avatar(
                  initials: _initialsOf(auditor.nombre),
                  bg: AppColors.primary800,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
          // Email
          Expanded(
            flex: _kColFlex[1],
            child: Text(
              auditor.email,
              style: AppTypography.monoData(11).copyWith(color: AppColors.primaryLink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Región (nullable)
          Expanded(
            flex: _kColFlex[2],
            child: Text(
              auditor.region ?? '—',
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.slate700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Estado
          Expanded(
            flex: _kColFlex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: AuditStatusBadge(estado: estadoBadge),
            ),
          ),
        ],
      ),
    );
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
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
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
