import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

// Tipografía AuditChain
// Inter → texto general
// JetBrains Mono → números, scores, IDs

TextTheme buildTextTheme() => GoogleFonts.interTextTheme();

TextStyle monoStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w700,
  Color color = const Color(0xFF0A2540),
}) =>
    GoogleFonts.jetBrainsMono(
        fontSize: fontSize, fontWeight: fontWeight, color: color);
