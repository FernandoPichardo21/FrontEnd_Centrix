import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'create_user_request.dart';
import 'created_user.dart';

class UserModel {
  UserModel({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<CreatedUser> create(CreateUserRequest request, String token) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/admin/users',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return CreatedUser.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        throw const ApiException(
          'Tu sesión venció. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }
      final data = error.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty && errors.first is Map) {
          final firstMessage = (errors.first as Map)['msg'];
          if (firstMessage is String) {
            throw ApiException(firstMessage, statusCode: statusCode);
          }
        }
        if (data['message'] is String) {
          throw ApiException(data['message'] as String, statusCode: statusCode);
        }
      }
      throw ApiException(
        'No se pudo crear el usuario. Inténtalo de nuevo.',
        statusCode: statusCode,
      );
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }
}
