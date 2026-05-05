import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

/// Badge tipo "pill" para representar el estado de una auditoría.
///
/// Mapea cada estado a un par de colores (fondo + texto) y a una etiqueta
/// legible. Los estados desconocidos caen en un estilo slate neutro.
class AuditStatusBadge extends StatelessWidget {
  const AuditStatusBadge({super.key, required this.estado});

  final String estado;

  static const Map<String, _BadgeStyle> _styles = <String, _BadgeStyle>{
    'completada': _BadgeStyle(
      background: Color(0xFFD1FAE5),
      foreground: Color(0xFF065F46),
    ),
    'pendiente': _BadgeStyle(
      background: Color(0xFFFEF3C7),
      foreground: Color(0xFF92400E),
    ),
    'con_observaciones': _BadgeStyle(
      background: Color(0xFFE0F2FE),
      foreground: Color(0xFF075985),
    ),
    'vencida': _BadgeStyle(
      background: Color(0xFFF1F5F9),
      foreground: Color(0xFF475569),
    ),
  };

  static String _labelFor(String estado) {
    if (estado == 'con_observaciones') return 'Con obs.';
    if (estado.isEmpty) return estado;
    final String normalized = estado.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final _BadgeStyle style = _styles[estado] ??
        _BadgeStyle(
          background: AppColors.slate100,
          foreground: AppColors.slate600,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _labelFor(estado),
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}
