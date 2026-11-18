import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'notification_item.dart';

class NotificationModel {
  NotificationModel(this._dio);

  final Dio _dio;

  Options _auth(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
    required String token,
    String? deviceName,
  }) async {
    try {
      final data = <String, dynamic>{
        'fcm_token': fcmToken,
        'platform': platform,
      };
      if (deviceName != null) {
        data['device_name'] = deviceName;
      }
      await _dio.post<Map<String, dynamic>>(
        '/api/users/device-token',
        data: data,
        options: _auth(token),
      );
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo registrar el dispositivo.');
    }
  }

  Future<void> unregisterDeviceToken({
    required String fcmToken,
    required String token,
  }) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/api/users/device-token',
        data: {'fcm_token': fcmToken},
        options: _auth(token),
      );
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo desregistrar el dispositivo.');
    }
  }

  Future<List<NotificationItem>> getNotifications(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/notifications',
        options: _auth(token),
      );
      final body = response.data;
      if (body == null || body['success'] != true || body['data'] is! List) {
        return const [];
      }
      final list = body['data'] as List;
      return list
          .map((item) => NotificationItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudieron cargar las notificaciones.');
    }
  }

  Future<void> markAsRead(String id, String token) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/api/notifications/$id/read',
        options: _auth(token),
      );
    } on DioException catch (error) {
      throw _apiException(error, 'No se pudo marcar la notificación.');
    }
  }

  ApiException _apiException(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(
        data['message'] as String,
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(fallback, statusCode: error.response?.statusCode);
  }
}
