import 'package:flutter/material.dart';
import '../../auth/data/models/user_model.dart';
import 'widgets/dashboard_shell.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      userName: user.fullName,
      userEmail: user.email,
      roleLabel: 'Panel de gerente',
      actions: const [
        DashboardAction(
          title: 'Tickets pendientes',
          subtitle: 'Revisa y asigna solicitudes del equipo',
          icon: Icons.assignment_outlined,
        ),
        DashboardAction(
          title: 'Gastos pendientes',
          subtitle: 'Aprueba o rechaza solicitudes de gasto',
          icon: Icons.price_check_outlined,
        ),
        DashboardAction(
          title: 'Mi equipo',
          subtitle: 'Consulta la actividad del equipo',
          icon: Icons.groups_outlined,
        ),
      ],
    );
  }
}
