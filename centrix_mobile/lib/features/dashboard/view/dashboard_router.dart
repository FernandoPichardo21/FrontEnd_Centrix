import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/viewmodel/login_viewmodel.dart';
import '../domain/user_role.dart';
import 'admin_dashboard_screen.dart';
import 'collaborator_dashboard_screen.dart';
import 'manager_dashboard_screen.dart';
import 'unsupported_role_screen.dart';

/// Selecciona el dashboard correspondiente al rol autenticado.
class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    void logout() {
      context.read<LoginViewModel>().logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }

    return switch (UserRole.fromBackend(user.role)) {
      UserRole.colaborador =>
        CollaboratorDashboardScreen(user: user, onLogout: logout),
      UserRole.gerente => ManagerDashboardScreen(user: user, onLogout: logout),
      UserRole.administrador =>
        AdminDashboardScreen(user: user, onLogout: logout),
      UserRole.desconocido => UnsupportedRoleScreen(role: user.role),
    };
  }
}
