import 'package:shared_preferences/shared_preferences.dart';

/// Manages JWT persistence via [SharedPreferences].
///
/// All methods are static — no instantiation needed.
/// Keys are kept private to this class; callers never touch raw strings.
class TokenStorage {
  TokenStorage._();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Persists both tokens after a successful login or token refresh.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns the stored access token, or `null` if absent.
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Returns the stored refresh token, or `null` if absent.
  static Future<String?> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Removes both tokens. Call on logout or after a 401 that cannot be
  /// recovered with a token refresh.
  static Future<void> clearTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ── Status ─────────────────────────────────────────────────────────────────

  /// Returns `true` when a non-empty access token is stored.
  static Future<bool> isLoggedIn() async {
    final String? token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
