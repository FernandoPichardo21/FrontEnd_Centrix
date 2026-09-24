import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/admin_user.dart';
import '../domain/admin_user_repository.dart';
import '../domain/create_user_request.dart';

class AdminUserRequestException implements Exception {
  const AdminUserRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Implementación HTTP del repositorio de usuarios administrativos.
class HttpAdminUserRepository implements AdminUserRepository {
  HttpAdminUserRepository({
    required http.Client client,
    required String baseUrl,
    required String token,
  })  : _client = client,
        _baseUrl = baseUrl,
        _token = token;

  final http.Client _client;
  final String _baseUrl;
  final String _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Consulta el directorio usando el JWT de la sesión administrativa.
  @override
  Future<List<AdminUser>> fetchAll() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/admin/users'),
        headers: _headers,
      );
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is! Map<String, dynamic> || body['data'] is! List) {
          throw const AdminUserRequestException(
            'El backend devolvió una lista no válida',
          );
        }

        return (body['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AdminUser.fromJson)
            .toList();
      }

      final message =
          body is Map<String, dynamic> ? body['message'] as String? : null;
      throw AdminUserRequestException(
        message ?? 'Error al consultar usuarios (${response.statusCode})',
      );
    } on AdminUserRequestException {
      rethrow;
    } on FormatException {
      throw const AdminUserRequestException(
        'El backend devolvió una respuesta no válida',
      );
    } catch (_) {
      throw const AdminUserRequestException(
        'No fue posible conectar con el backend',
      );
    }
  }

  /// Envía los datos del formulario para registrar una cuenta nueva.
  @override
  Future<void> create(CreateUserRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/admin/users'),
        headers: _headers,
        body: jsonEncode(request.toBackendJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) return;

      final body = jsonDecode(response.body);
      final message =
          body is Map<String, dynamic> ? body['message'] as String? : null;
      throw AdminUserRequestException(
        message ?? 'Error al crear el usuario (${response.statusCode})',
      );
    } on AdminUserRequestException {
      rethrow;
    } on FormatException {
      throw const AdminUserRequestException(
        'El backend devolvió una respuesta no válida',
      );
    } catch (_) {
      throw const AdminUserRequestException(
        'No fue posible conectar con el backend',
      );
    }
  }
}
