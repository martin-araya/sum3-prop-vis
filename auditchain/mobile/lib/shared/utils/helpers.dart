import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_routes.dart';

// DD/MM/YYYY
String formatFecha(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return iso;
  return '${p[2]}/${p[1]}/${p[0]}';
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
    backgroundColor:
        error ? const Color(0xFFEF4444) : const Color(0xFF1E3A8A),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(12),
  ));
}

// API helpers
Future<List<Auditoria>> fetchAuditorias() async {
  final data = await DioClient.get(ApiRoutes.auditorias) as List<dynamic>;
  return data.map((e) => Auditoria.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<Sucursal>> fetchSucursales() async {
  final data = await DioClient.get(ApiRoutes.sucursales) as List<dynamic>;
  return data.map((e) => Sucursal.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<Auditor>> fetchAuditores() async {
  final data = await DioClient.get(ApiRoutes.auditores) as List<dynamic>;
  return data.map((e) => Auditor.fromJson(e as Map<String, dynamic>)).toList();
}
