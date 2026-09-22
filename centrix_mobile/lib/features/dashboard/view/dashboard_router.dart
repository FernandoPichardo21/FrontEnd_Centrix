import 'package:flutter/material.dart';
import '../../auth/data/models/user_model.dart';
import '../domain/user_role.dart';
import 'admin_dashboard_screen.dart';
import 'collaborator_dashboard_screen.dart';
import 'manager_dashboard_screen.dart';
import 'unsupported_role_screen.dart';

class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return switch (UserRole.fromBackend(user.role)) {
      UserRole.colaborador => CollaboratorDashboardScreen(user: user),
      UserRole.gerente => ManagerDashboardScreen(user: user),
      UserRole.administrador => AdminDashboardScreen(user: user),
      UserRole.desconocido => UnsupportedRoleScreen(role: user.role),
    };
  }
}
