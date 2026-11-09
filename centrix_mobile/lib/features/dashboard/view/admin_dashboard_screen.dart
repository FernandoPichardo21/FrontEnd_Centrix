import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/viewmodel/login_viewmodel.dart';
import '../../admin/users/admin_users_module.dart';
import 'widgets/dashboard_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final UserModel user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      userName: user.fullName,
      userEmail: user.email,
      roleLabel: 'Panel de administración',
      onLogout: onLogout,
      actions: [
        const DashboardAction(
          title: 'Reportes',
          subtitle: 'Disponible en una próxima historia',
          icon: Icons.analytics_outlined,
          enabled: false,
        ),
        const DashboardAction(
          title: 'Auditoría',
          subtitle: 'Disponible en una próxima historia',
          icon: Icons.fact_check_outlined,
          enabled: false,
        ),
        DashboardAction(
          title: 'Usuarios y roles',
          subtitle: 'Administra el acceso de los usuarios',
          icon: Icons.manage_accounts_outlined,
          enabled: true,
          onTap: () {
            final token = context.read<LoginViewModel>().token;
            if (token == null || token.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('La sesión no tiene un token válido')),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AdminUsersModule.build(token: token),
              ),
            );
          },
        ),
      ],
    );
  }
}
