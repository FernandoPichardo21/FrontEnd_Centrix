import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'manager_request.dart';

class ManagerApiService {
  ManagerApiService({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<List<ManagerRequest>> fetchDepartmentRequests(
    String token, {
    String? departmentId,
    String? status,
    String? category,
    String? search,
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': 100,
        if (departmentId != null && departmentId.isNotEmpty)
          'department_id': departmentId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        'month': ?month,
        'year': ?year,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/resource-requests/department',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }

      final dataMap = Map<String, dynamic>.from(body['data'] as Map);
      final items = (dataMap['items'] as List<dynamic>? ?? []);
      return items
          .map(
            (item) =>
                ManagerRequest.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar solicitudes del departamento.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> fetchBudget(
    String token, {
    String? departmentId,
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (departmentId != null && departmentId.isNotEmpty)
          'department_id': departmentId,
        'month': ?month,
        'year': ?year,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/resource-requests/department/budget',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException(
          'Respuesta inesperada al consultar presupuesto.',
        );
      }

      return Map<String, dynamic>.from(body['data'] as Map);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al consultar presupuesto.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> updateBudget(
    String token, {
    String? departmentId,
    int? month,
    int? year,
    required Map<String, int> allocations,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/resource-requests/department/budget',
        data: {
          if (departmentId != null && departmentId.isNotEmpty)
            'department_id': departmentId,
          'month': ?month,
          'year': ?year,
          'allocations': allocations,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException(
          'Respuesta inesperada al actualizar presupuesto.',
        );
      }

      return Map<String, dynamic>.from(body['data'] as Map);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al actualizar presupuesto.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> decideRequest(
    String token, {
    required String requestId,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/resource-requests/$requestId/decision',
        data: {
          'status': status,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw const ApiException('No se pudo registrar la decisión.');
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al registrar decisión.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> fetchReport(
    String token, {
    String? departmentId,
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (departmentId != null && departmentId.isNotEmpty)
          'department_id': departmentId,
        'month': ?month,
        'year': ?year,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/resource-requests/department/report',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('Respuesta inesperada al generar reporte.');
      }

      return Map<String, dynamic>.from(body['data'] as Map);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ?? 'Error al generar reporte.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<ManagerRequest>> fetchMyRequests(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/resource-requests/mine',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }

      return (body['data'] as List)
          .map(
            (item) =>
                ManagerRequest.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al consultar mis solicitudes.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<String> createRequest(
    String token, {
    required String title,
    required String description,
    required String category,
    required double estimatedAmount,
    String? departmentId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/resource-requests',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'estimated_amount': estimatedAmount,
          if (departmentId != null && departmentId.isNotEmpty)
            'department_id': departmentId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('No se pudo crear la solicitud de recurso.');
      }

      return body['data']['id'].toString();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ?? 'Error al crear solicitud.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteRequest(String token, String requestId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/api/resource-requests/$requestId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        throw const ApiException('No se pudo cancelar la solicitud.');
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message']?.toString() ??
            'Error al cancelar solicitud.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
