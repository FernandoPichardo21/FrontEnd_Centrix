import '../../auth/models/auth_user.dart';
import '../models/dashboard_module.dart';

class DashboardViewModel {
  DashboardViewModel(this.user);

  final AuthUser user;

  String get displayName {
    final name = user.fullName.trim();
    return name.isEmpty ? user.email : name;
  }

  List<String> get roleLabels {
    final values = <String>{
      ...user.roles.map((role) => role.toLowerCase().trim()),
      user.role.toLowerCase().trim(),
    }..removeWhere((role) => role.isEmpty || role == 'sin_rol');
    if (values.isEmpty) return const ['Sin rol asignado'];
    return values.map(_labelForRole).toList(growable: false);
  }

  List<DashboardModule> get modules {
    return [
      if (user.canCreateTicket) DashboardModule.createTicket,
      DashboardModule.myTickets,
      if (user.canManageTickets) DashboardModule.pendingTickets,
      if (user.canViewDepartmentTickets) DashboardModule.departmentTickets,
      DashboardModule.departments,
      if (user.canCreateUser) DashboardModule.createUser,
    ];
  }

  static String _labelForRole(String role) => switch (role) {
    'administrador' => 'Administrador',
    'gerente' => 'Gerente',
    'colaborador' => 'Colaborador',
    'soporte_tecnico' => 'Soporte técnico',
    'soporte' => 'Soporte',
    _ => role,
  };
}
