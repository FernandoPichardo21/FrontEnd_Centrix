import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Manejo de mensaje en segundo plano o app cerrada
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize({
    Function(RemoteMessage)? onNotificationTapped,
  }) async {
    if (!isSupported || _isInitialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Configuración de notificaciones locales para Android en primer plano
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Usuario tocó la notificación local
        },
      );

      // Crear canal de alta importancia en Android
      const channel = AndroidNotificationChannel(
        'centrix_high_importance_channel',
        'Notificaciones de Centrix',
        description: 'Canal principal para alertas y notificaciones de tickets',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Escuchar cuando el usuario abre la app desde una notificación
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (onNotificationTapped != null) {
          onNotificationTapped(message);
        }
      });

      // Escuchar notificaciones mientras la app está abierta (foreground)
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'centrix_high_importance_channel',
                'Notificaciones de Centrix',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[PushNotificationService] Error inicializando: $e');
    }
  }

  Future<String?> requestToken() async {
    if (!isSupported) return null;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        return await messaging.getToken();
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Error solicitando token: $e');
    }
    return null;
  }
}
