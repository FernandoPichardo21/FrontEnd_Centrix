import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/centrix_theme.dart';
import 'core/widgets/centrix_glass.dart';
import 'features/auth/models/auth_model.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/admin_users/models/user_model.dart';
import 'features/departments/models/department_model.dart';
import 'features/tickets/models/ticket_model.dart';

class CentrixApp extends StatefulWidget {
  const CentrixApp({
    super.key,
    this.authModel,
    this.departmentModel,
    this.ticketModel,
    this.userModel,
  });

  final AuthModel? authModel;
  final DepartmentModel? departmentModel;
  final TicketModel? ticketModel;
  final UserModel? userModel;

  @override
  State<CentrixApp> createState() => _CentrixAppState();
}

class _CentrixAppState extends State<CentrixApp> {
  late final AuthViewModel _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthViewModel(widget.authModel ?? AuthModel());
    _router = createAppRouter(
      _auth,
      widget.departmentModel ?? DepartmentModel(),
      widget.ticketModel ?? TicketModel(),
      widget.userModel ?? UserModel(),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'Centrix',
        debugShowCheckedModeBanner: false,
        theme: CentrixTheme.dark,
        builder: (context, child) => CentrixBackdrop(
          dark: true,
          child: child ?? const SizedBox.shrink(),
        ),
        routerConfig: _router,
      ),
    );
  }
}
