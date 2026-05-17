// Rutas de la API — configurable via --dart-define=API_URL
class ApiRoutes {
  static const String _base = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.43:8000/api',
  );

  static String get base => _base;

  // Auth
  static String get login => '$_base/auth/login';

  // Recursos
  static String get auditorias => '$_base/auditorias/';
  static String get sucursales => '$_base/sucursales/';
  static String get auditores => '$_base/auditores/';
  static String get usuarios => '$_base/usuarios/';

  // Con ID
  static String auditoria(String id) => '$_base/auditorias/$id';
  static String sucursal(String id) => '$_base/sucursales/$id';
}
