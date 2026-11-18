import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config/api_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/centrix_theme.dart';
import 'core/widgets/centrix_glass.dart';
import 'features/auth/models/auth_model.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/admin_users/models/user_model.dart';
import 'features/departments/models/department_model.dart';
import 'features/tickets/models/ticket_model.dart';
import 'features/notifications/models/notification_model.dart';
import 'features/notifications/viewmodels/notification_view_model.dart';
import 'features/notifications/services/push_notification_service.dart';

class CentrixApp extends StatefulWidget {
  const CentrixApp({
    super.key,
    this.authModel,
    this.departmentModel,
    this.ticketModel,
    this.userModel,
    this.notificationModel,
  });

  final AuthModel? authModel;
  final DepartmentModel? departmentModel;
  final TicketModel? ticketModel;
  final UserModel? userModel;
  final NotificationModel? notificationModel;

  @override
  State<CentrixApp> createState() => _CentrixAppState();
}

class _CentrixAppState extends State<CentrixApp> {
  late final AuthViewModel _auth;
  late final NotificationViewModel _notificationVm;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthViewModel(widget.authModel ?? AuthModel());
    _notificationVm = NotificationViewModel(
      widget.notificationModel ??
          NotificationModel(
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            ),
          ),
    );

    _router = createAppRouter(
      _auth,
      widget.departmentModel ?? DepartmentModel(),
      widget.ticketModel ?? TicketModel(),
      widget.userModel ?? UserModel(),
    );

    _auth.addListener(_onAuthChanged);

    // Configurar apertura directa del ticket desde notificaciones push
    PushNotificationService.instance.initialize(
      onNotificationTapped: (message) {
        final ticketId = message.data['ticket_id']?.toString();
        if (ticketId != null && ticketId.isNotEmpty) {
          _router.push('/tickets/$ticketId');
        }
      },
    );
  }

  void _onAuthChanged() {
    final session = _auth.session;
    if (session != null) {
      _notificationVm.initializePush(session.token);
      _notificationVm.load(session.token);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _router.dispose();
    _notificationVm.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: _auth),
        ChangeNotifierProvider<NotificationViewModel>.value(
          value: _notificationVm,
        ),
      ],
      child: MaterialApp.router(
        title: 'Centrix',
        debugShowCheckedModeBanner: false,
        theme: CentrixTheme.light,
        builder: (context, child) =>
            CentrixBackdrop(child: child ?? const SizedBox.shrink()),
        routerConfig: _router,
      ),
    );
  }
}
