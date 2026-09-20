import 'package:flutter/material.dart';
import '../../auth/data/models/user_model.dart';
import 'widgets/dashboard_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      userName: user.fullName,
      userEmail: user.email,
      roleLabel: 'Panel de administración',
      actions: const [
        DashboardAction(
          title: 'Reportes',
          subtitle: 'Consulta métricas globales de Centrix',
          icon: Icons.analytics_outlined,
        ),
        DashboardAction(
          title: 'Auditoría',
          subtitle: 'Revisa la actividad del sistema',
          icon: Icons.fact_check_outlined,
        ),
        DashboardAction(
          title: 'Usuarios y roles',
          subtitle: 'Administra accesos y permisos',
          icon: Icons.manage_accounts_outlined,
        ),
      ],
    );
  }
}
