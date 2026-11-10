import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'create_ticket_request.dart';
import 'created_ticket.dart';
import 'ticket.dart';
import 'ticket_assignee.dart';
import 'ticket_status.dart';
import 'ticket_evidence.dart';
import 'ticket_evidence_file.dart';

class TicketModel {
  TicketModel({Dio? client}) : _dio = client ?? createApiClient();

  final Dio _dio;

  Future<CreatedTicket> create(
    CreateTicketRequest request,
    String token,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/tickets',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return CreatedTicket.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      throw _apiException(
        error,
        'No se pudo crear el ticket. Inténtalo de nuevo.',
      );
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<List<Ticket>> getByDepartment(
    String departmentId,
    String token,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/tickets/department?department_id=${Uri.encodeComponent(departmentId)}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return (body['data'] as List)
          .map(
            (item) => Ticket.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudieron cargar los tickets.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<List<Ticket>> getMyTickets(String token) =>
      _getTickets('/api/tickets/mine', token);

  Future<List<Ticket>> getPendingTickets(String token) =>
      _getTickets('/api/tickets/pending', token);

  Future<Ticket> getById(String ticketId, String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/tickets/${Uri.encodeComponent(ticketId)}',
        options: _auth(token),
      );
      final data = _responseData(response.data);
      if (data is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return Ticket.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo cargar el ticket.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<List<TicketAssignee>> getAssignees(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/tickets/assignees',
        options: _auth(token),
      );
      final data = _responseData(response.data);
      if (data is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return data
          .map(
            (item) =>
                TicketAssignee.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudieron cargar los usuarios.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<void> assign(String ticketId, String assigneeId, String token) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/tickets/${Uri.encodeComponent(ticketId)}/assign',
        data: {'assigneeId': assigneeId},
        options: _auth(token),
      );
      _responseData(response.data);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo asignar el ticket.');
    }
  }

  Future<void> updateStatus(
    String ticketId,
    TicketStatus status,
    String token,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/tickets/${Uri.encodeComponent(ticketId)}/status',
        data: {'status': status.apiValue},
        options: _auth(token),
      );
      _responseData(response.data);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo cambiar el estado.');
    }
  }

  Future<List<TicketEvidence>> getEvidences(
    String ticketId,
    String token,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/tickets/${Uri.encodeComponent(ticketId)}/evidences',
        options: _auth(token),
      );
      final data = _responseData(response.data);
      if (data is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return data
          .map(
            (item) =>
                TicketEvidence.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudieron cargar las evidencias.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<TicketEvidence> attachEvidence(
    String ticketId,
    TicketEvidenceFile file,
    String token,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/tickets/${Uri.encodeComponent(ticketId)}/evidences',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            file.bytes,
            filename: file.name,
            contentType: DioMediaType.parse(file.mimeType),
          ),
        }),
        options: _auth(token),
      );
      final data = _responseData(response.data);
      if (data is! Map) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return TicketEvidence.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo adjuntar la evidencia.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Future<List<Ticket>> _getTickets(String path, String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        options: _auth(token),
      );
      final data = _responseData(response.data);
      if (data is! List) {
        throw const ApiException('Respuesta inesperada del servidor.');
      }
      return data
          .map(
            (item) => Ticket.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudieron cargar los tickets.');
    } on TypeError {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
  }

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  dynamic _responseData(Map<String, dynamic>? body) {
    if (body == null || body['success'] != true || !body.containsKey('data')) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return body['data'];
  }

  ApiException _apiException(DioException error, String fallbackMessage) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return const ApiException(
        'Tu sesión venció. Inicia sesión de nuevo.',
        statusCode: 401,
      );
    }
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String, statusCode: statusCode);
    }
    return ApiException(fallbackMessage, statusCode: statusCode);
  }
}
