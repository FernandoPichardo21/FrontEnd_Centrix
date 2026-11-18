import 'package:centrix/features/notifications/models/notification_item.dart';
import 'package:centrix/features/notifications/models/notification_model.dart';
import 'package:centrix/features/notifications/viewmodels/notification_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registra token de dispositivo con Bearer y cuerpo esperado', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Token registrado exitosamente',
              },
            ),
          );
        },
      ),
    );

    final model = NotificationModel(dio);
    await model.registerDeviceToken(
      fcmToken: 'fcm-token-123',
      platform: 'android',
      token: 'jwt-token-abc',
      deviceName: 'Pixel 7',
    );

    expect(sentRequest, isNotNull);
    expect(sentRequest!.path, '/api/users/device-token');
    expect(sentRequest!.headers['Authorization'], 'Bearer jwt-token-abc');
    expect(sentRequest!.data, {
      'fcm_token': 'fcm-token-123',
      'platform': 'android',
      'device_name': 'Pixel 7',
    });
  });

  test('obtiene y deserializa notificaciones correctamente', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': [
                  {
                    'id': 'notif-1',
                    'title': 'Nuevo ticket',
                    'body': 'Se te asignó el ticket',
                    'type': 'ticket_assigned',
                    'is_read': false,
                    'ticket_id': 'ticket-99',
                    'created_at': '2026-11-12T10:00:00Z',
                  },
                  {
                    'id': 'notif-2',
                    'title': 'Ticket resuelto',
                    'body': 'El ticket fue resuelto',
                    'type': 'status_changed',
                    'is_read': true,
                    'created_at': '2026-11-12T09:00:00Z',
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final model = NotificationModel(dio);
    final vm = NotificationViewModel(model);

    await vm.load('jwt-token-abc');

    expect(vm.notifications.length, 2);
    expect(vm.unreadCount, 1);
    expect(vm.notifications.first.ticketId, 'ticket-99');
    expect(vm.notifications.first.isRead, false);
    expect(vm.notifications.last.isRead, true);
  });

  test('marca notificación como leída y actualiza estado local', () async {
    RequestOptions? patchRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          patchRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ),
          );
        },
      ),
    );

    final model = NotificationModel(dio);
    final vm = NotificationViewModel(model);

    vm.addNotification(
      NotificationItem(
        id: 'notif-1',
        title: 'Prueba',
        body: 'Cuerpo',
        type: 'general',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    expect(vm.unreadCount, 1);

    await vm.markAsRead('notif-1', 'jwt-token-abc');

    expect(patchRequest?.path, '/api/notifications/notif-1/read');
    expect(vm.unreadCount, 0);
    expect(vm.notifications.first.isRead, true);
  });
}
