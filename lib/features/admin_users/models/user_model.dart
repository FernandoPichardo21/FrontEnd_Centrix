import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'create_user_request.dart';
import 'created_user.dart';
import 'user_role_option.dart';

class UserModel {
  UserModel({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<List<UserRoleOption>> getRoles(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/admin/roles',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! List) {
        throw const ApiException('No se pudo leer el catálogo de roles.');
      }
      return (body['data'] as List)
          .map(
            (item) =>
                UserRoleOption.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw ApiException(
        status == 404
            ? 'Actualiza y reinicia el backend para cargar los roles disponibles.'
            : status == 401
            ? 'Tu sesión venció. Inicia sesión de nuevo.'
            : 'No se pudieron cargar los roles.',
        statusCode: status,
      );
    } on TypeError {
      throw const ApiException('No se pudo leer el catálogo de roles.');
    }
  }

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
