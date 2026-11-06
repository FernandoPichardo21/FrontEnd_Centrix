import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_session.dart';

/// Obtiene y transforma los datos de autenticación del backend.
class AuthModel {
  AuthModel({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return AuthSession.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw const ApiException('No se pudo conectar con el servidor.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }
}
