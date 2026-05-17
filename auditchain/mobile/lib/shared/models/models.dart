class Sucursal {
  final String id, nombre, region, estado;
  final double puntajePromedio;
  Sucursal({required this.id, required this.nombre, required this.region,
      required this.estado, required this.puntajePromedio});
  factory Sucursal.fromJson(Map<String, dynamic> j) => Sucursal(
        id: j['id'], nombre: j['nombre'], region: j['region'],
        estado: j['estado'],
        puntajePromedio: (j['puntaje_promedio'] as num).toDouble());
}

class Auditor {
  final String id, nombre, email, estado;
  final String? region;
  Auditor({required this.id, required this.nombre, required this.email,
      required this.estado, this.region});
  factory Auditor.fromJson(Map<String, dynamic> j) => Auditor(
        id: j['id'], nombre: j['nombre'], email: j['email'],
        estado: j['estado'], region: j['region']);
}

class Auditoria {
  final String id, sucursalId, auditorId, fecha, estado;
  final int puntaje;
  final String? notas;
  Auditoria({required this.id, required this.sucursalId,
      required this.auditorId, required this.fecha,
      required this.puntaje, required this.estado, this.notas});
  factory Auditoria.fromJson(Map<String, dynamic> j) => Auditoria(
        id: j['id'], sucursalId: j['sucursal_id'],
        auditorId: j['auditor_id'], fecha: j['fecha'],
        puntaje: j['puntaje'], estado: j['estado'], notas: j['notas']);
}
