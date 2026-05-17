import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes.dart';

// Cliente HTTP con interceptor JWT
// Adjunta el Bearer token en cada request autenticado

class DioClient {
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String url) async {
    final res = await http.get(Uri.parse(url), headers: await _authHeaders());
    _assertOk(res);
    return jsonDecode(res.body);
  }

  static Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(url),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    _assertOk(res);
    return jsonDecode(res.body);
  }

  static Future<dynamic> postForm(String url, Map<String, String> fields) async {
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: fields.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&'),
    );
    _assertOk(res);
    return jsonDecode(res.body);
  }

  static void _assertOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['detail'] ?? 'Error ${res.statusCode}');
    }
  }
}

// Servicio de autenticación
class AuthClient {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final data = await DioClient.postForm(ApiRoutes.login, {
      'username': email,
      'password': password,
    }) as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['access_token'] as String);
    await prefs.setString(_userKey, jsonEncode(data['usuario']));
    return data;
  }

  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  static Future<Map<String, dynamic>?> getUser() async {
    final s =
        (await SharedPreferences.getInstance()).getString(_userKey);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }
}
