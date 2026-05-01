// ─── Sucursal ─────────────────────────────────────────────────────────────────
class Sucursal {
  final String id;
  final String nombre;
  final String region;
  final String? direccion;
  final String estado;
  final double puntajePromedio;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.region,
    this.direccion,
    required this.estado,
    required this.puntajePromedio,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) => Sucursal(
        id: json['id'],
        nombre: json['nombre'],
        region: json['region'],
        direccion: json['direccion'],
        estado: json['estado'],
        puntajePromedio: (json['puntaje_promedio'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'region': region,
        'direccion': direccion,
        'estado': estado,
      };
}

// ─── Auditor ──────────────────────────────────────────────────────────────────
class Auditor {
  final String id;
  final String nombre;
  final String email;
  final String? region;
  final String estado;

  Auditor({
    required this.id,
    required this.nombre,
    required this.email,
    this.region,
    required this.estado,
  });

  factory Auditor.fromJson(Map<String, dynamic> json) => Auditor(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        region: json['region'],
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'region': region,
        'estado': estado,
      };
}

// ─── Auditoria ────────────────────────────────────────────────────────────────
class Auditoria {
  final String id;
  final String sucursalId;
  final String auditorId;
  final String fecha;
  final int puntaje;
  final String estado;
  final String? notas;

  Auditoria({
    required this.id,
    required this.sucursalId,
    required this.auditorId,
    required this.fecha,
    required this.puntaje,
    required this.estado,
    this.notas,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) => Auditoria(
        id: json['id'],
        sucursalId: json['sucursal_id'],
        auditorId: json['auditor_id'],
        fecha: json['fecha'],
        puntaje: json['puntaje'],
        estado: json['estado'],
        notas: json['notas'],
      );

  Map<String, dynamic> toJson() => {
        'sucursal_id': sucursalId,
        'auditor_id': auditorId,
        'fecha': fecha,
        'puntaje': puntaje,
        'estado': estado,
        'notas': notas,
      };
}

// ─── Usuario ──────────────────────────────────────────────────────────────────
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        rol: json['rol'],
        activo: json['activo'],
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'activo': activo,
      };
}
