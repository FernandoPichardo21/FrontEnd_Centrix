import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/notification_item.dart';
import '../models/notification_model.dart';
import '../services/push_notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this._model);

  final NotificationModel _model;

  List<NotificationItem> _notifications = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFcmToken;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initializePush(String sessionToken) async {
    final pushService = PushNotificationService.instance;
    await pushService.initialize();

    final fcmToken = await pushService.requestToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      _currentFcmToken = fcmToken;
      final platform = kIsWeb
          ? 'web'
          : Platform.isAndroid
              ? 'android'
              : 'ios';
      try {
        await _model.registerDeviceToken(
          fcmToken: fcmToken,
          platform: platform,
          token: sessionToken,
        );
      } catch (e) {
        debugPrint('[NotificationViewModel] Error registrando token en backend: $e');
      }
    }
  }

  Future<void> load(String token) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _model.getNotifications(token);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las notificaciones.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id, String token) async {
    try {
      await _model.markAsRead(id, token);
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(growable: false);
      notifyListeners();
    } catch (_) {}
  }

  void addNotification(NotificationItem item) {
    _notifications = [item, ..._notifications];
    notifyListeners();
  }

  Future<void> unregisterPush(String sessionToken) async {
    if (_currentFcmToken != null) {
      try {
        await _model.unregisterDeviceToken(
          fcmToken: _currentFcmToken!,
          token: sessionToken,
        );
      } catch (_) {}
      _currentFcmToken = null;
    }
    _notifications = const [];
    notifyListeners();
  }
}
