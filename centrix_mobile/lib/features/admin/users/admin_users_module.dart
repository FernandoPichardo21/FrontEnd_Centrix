import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../config/api_config.dart';
import 'data/http_admin_user_repository.dart';
import 'view/admin_users_screen.dart';
import 'viewmodel/admin_users_viewmodel.dart';

/// Compone las dependencias necesarias para administrar usuarios.
class AdminUsersModule {
  const AdminUsersModule._();

  static Widget build({required String token}) {
    return ChangeNotifierProvider(
      create: (_) => AdminUsersViewModel(
        HttpAdminUserRepository(
          client: http.Client(),
          baseUrl: ApiConfig.baseUrl,
          token: token,
        ),
      )..loadUsers(),
      child: const AdminUsersScreen(),
    );
  }
}
