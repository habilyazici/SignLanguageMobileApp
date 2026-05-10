import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class UnauthorizedException implements Exception {}

extension AuthHttpClient on Ref {
  String? get _token => read(authProvider).token;

  Map<String, String> _getHeaders({bool isJson = false}) => {
        ...kNgrokHeaders,
        if (_token != null) 'Authorization': 'Bearer $_token',
        if (isJson) 'Content-Type': 'application/json',
      };

  http.Response _checked(http.Response res) {
    if (res.statusCode == 401) {
      read(authProvider.notifier).signOut();
      throw UnauthorizedException();
    }
    return res;
  }

  Future<http.Response> apiGet(String path) async {
    final res = await http
        .get(Uri.parse('$kApiBaseUrl$path'), headers: _getHeaders())
        .timeout(kApiTimeout);
    return _checked(res);
  }

  Future<http.Response> apiPost(String path, {Object? body}) async {
    final res = await http
        .post(
          Uri.parse('$kApiBaseUrl$path'),
          headers: _getHeaders(isJson: true),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(kApiTimeout);
    return _checked(res);
  }

  Future<http.Response> apiDelete(String path) async {
    final res = await http
        .delete(Uri.parse('$kApiBaseUrl$path'), headers: _getHeaders())
        .timeout(kApiTimeout);
    return _checked(res);
  }
}
