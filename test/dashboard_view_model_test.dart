import 'package:centrix/features/auth/models/auth_user.dart';
import 'package:centrix/features/dashboard/models/dashboard_module.dart';
import 'package:centrix/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DashboardViewModel dashboardFor(List<String> roles) {
    return DashboardViewModel(
      AuthUser(
        id: 'user-1',
        email: 'usuario@empresa.com',
        fullName: 'Usuario de prueba',
        role: roles.first,
        roles: roles,
      ),
    );
  }

  test('los módulos respetan los permisos de cada rol', () {
    expect(dashboardFor(['colaborador']).modules, [
      DashboardModule.createTicket,
      DashboardModule.myTickets,
      DashboardModule.departments,
    ]);
    expect(dashboardFor(['gerente']).modules, [
      DashboardModule.managerApprovals,
      DashboardModule.managerBudget,
      DashboardModule.managerRequests,
      DashboardModule.managerReports,
      DashboardModule.createTicket,
      DashboardModule.myTickets,
      DashboardModule.pendingTickets,
      DashboardModule.departmentTickets,
      DashboardModule.departments,
    ]);
    expect(dashboardFor(['administrador']).modules, [
      DashboardModule.createTicket,
      DashboardModule.myTickets,
      DashboardModule.pendingTickets,
      DashboardModule.departmentTickets,
      DashboardModule.departments,
      DashboardModule.createUser,
    ]);
    expect(dashboardFor(['soporte_tecnico']).modules, [
      DashboardModule.myTickets,
      DashboardModule.departments,
    ]);
  });

  test('un usuario con varios roles conserva la unión de permisos', () {
    expect(dashboardFor(['colaborador', 'administrador']).modules, [
      DashboardModule.createTicket,
      DashboardModule.myTickets,
      DashboardModule.pendingTickets,
      DashboardModule.departmentTickets,
      DashboardModule.departments,
      DashboardModule.createUser,
    ]);
  });
}
