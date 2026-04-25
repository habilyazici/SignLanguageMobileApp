import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

const _kTokenKey = 'auth_token';
const _kNameKey = 'auth_name';
const _kEmailKey = 'auth_email';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$kApiBaseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final token = body['token'] as String;
        final user = body['user'] as Map<String, dynamic>;
        await _saveSession(
          token: token,
          name: user['name'] as String,
          email: user['email'] as String,
        );
        return AuthState(
          status: AuthStatus.authenticated,
          token: token,
          displayName: user['name'] as String,
          email: user['email'] as String,
        );
      }

      return AuthState(
        status: AuthStatus.guest,
        errorMessage: body['error'] as String? ?? 'Giriş başarısız.',
      );
    } catch (_) {
      return const AuthState(
        status: AuthStatus.guest,
        errorMessage: 'Sunucuya bağlanılamadı.',
      );
    }
  }

  @override
  Future<AuthState> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$kApiBaseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 201) {
        final token = body['token'] as String;
        final user = body['user'] as Map<String, dynamic>;
        await _saveSession(
          token: token,
          name: user['name'] as String,
          email: user['email'] as String,
        );
        return AuthState(
          status: AuthStatus.authenticated,
          token: token,
          displayName: user['name'] as String,
          email: user['email'] as String,
        );
      }

      return AuthState(
        status: AuthStatus.guest,
        errorMessage: body['error'] as String? ?? 'Kayıt başarısız.',
      );
    } catch (_) {
      return const AuthState(
        status: AuthStatus.guest,
        errorMessage: 'Sunucuya bağlanılamadı.',
      );
    }
  }

  /// Uygulama açılışında kayıtlı oturumu geri yükler.
  Future<AuthState> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final name = prefs.getString(_kNameKey);
    final email = prefs.getString(_kEmailKey);
    if (token == null || email == null) return const AuthState();
    return AuthState(
      status: AuthStatus.authenticated,
      token: token,
      displayName: name,
      email: email,
    );
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kNameKey);
    await prefs.remove(_kEmailKey);
  }

  Future<void> _saveSession({
    required String token,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    await prefs.setString(_kNameKey, name);
    await prefs.setString(_kEmailKey, email);
  }
}
