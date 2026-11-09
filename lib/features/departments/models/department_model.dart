import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'department.dart';

class DepartmentModel {
  DepartmentModel({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<List<Department>> fetchAll(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/departments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return (body['data'] as List)
          .map(
            (item) =>
                Department.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        throw const ApiException(
          'Tu sesión venció. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String, statusCode: statusCode);
      }
      throw ApiException(
        'No se pudieron cargar los departamentos.',
        statusCode: statusCode,
      );
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }
}
