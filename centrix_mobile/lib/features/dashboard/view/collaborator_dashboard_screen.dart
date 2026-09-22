import 'package:flutter/material.dart';
import '../../auth/data/models/user_model.dart';
import 'widgets/dashboard_shell.dart';

class CollaboratorDashboardScreen extends StatelessWidget {
  const CollaboratorDashboardScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      userName: user.fullName,
      userEmail: user.email,
      roleLabel: 'Panel de colaborador',
      actions: const [
        DashboardAction(
          title: 'Mis tickets',
          subtitle: 'Consulta el estado de tus solicitudes',
          icon: Icons.confirmation_number_outlined,
        ),
        DashboardAction(
          title: 'Nuevo ticket',
          subtitle: 'Registra una nueva solicitud',
          icon: Icons.add_circle_outline,
        ),
        DashboardAction(
          title: 'Mis gastos',
          subtitle: 'Consulta y registra tus gastos',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }
}
