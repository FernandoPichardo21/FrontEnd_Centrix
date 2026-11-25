import 'package:flutter/material.dart';

import '../../models/dashboard_module.dart';

extension DashboardModuleInfo on DashboardModule {
  String get title => switch (this) {
    DashboardModule.createTicket => 'Crear ticket',
    DashboardModule.myTickets => 'Mis tickets',
    DashboardModule.pendingTickets => 'Tickets pendientes',
    DashboardModule.departmentTickets => 'Tickets por departamento',
    DashboardModule.departments => 'Departamentos',
    DashboardModule.createUser => 'Crear usuario',
    DashboardModule.userManagement => 'Gestión de usuarios',
    DashboardModule.managerApprovals => 'Aprobaciones',
    DashboardModule.managerBudget => 'Presupuesto',
    DashboardModule.managerRequests => 'Solicitudes del departamento',
    DashboardModule.managerReports => 'Reportes',
    DashboardModule.createResourceRequest => 'Pedir recursos',
    DashboardModule.myResourceRequests => 'Mis recursos solicitados',
  };

  String get description => switch (this) {
    DashboardModule.createTicket => 'Reporta una nueva incidencia',
    DashboardModule.myTickets => 'Seguimiento de tus incidencias',
    DashboardModule.pendingTickets => 'Revisa lo que necesita atención',
    DashboardModule.departmentTickets => 'Incidencias de tu departamento',
    DashboardModule.departments => 'Conoce a las áreas de tu equipo',
    DashboardModule.createUser => 'Agrega una cuenta al equipo',
    DashboardModule.userManagement => 'Administra cuentas, roles y departamentos',
    DashboardModule.managerApprovals => 'Revisa solicitudes de tu equipo',
    DashboardModule.managerBudget => 'Recursos y presupuesto del área',
    DashboardModule.managerRequests => 'Movimientos del equipo',
    DashboardModule.managerReports => 'Resultados y métricas del área',
    DashboardModule.createResourceRequest => 'Solicita equipo, material o presupuesto',
    DashboardModule.myResourceRequests => 'Consulta el estado de tus solicitudes',
  };

  IconData get icon => switch (this) {
    DashboardModule.createTicket => Icons.add_rounded,
    DashboardModule.myTickets => Icons.confirmation_number_outlined,
    DashboardModule.pendingTickets => Icons.assignment_outlined,
    DashboardModule.departmentTickets => Icons.view_list_outlined,
    DashboardModule.departments => Icons.apartment_rounded,
    DashboardModule.createUser => Icons.person_add_alt_1_rounded,
    DashboardModule.userManagement => Icons.manage_accounts_rounded,
    DashboardModule.managerApprovals => Icons.fact_check_outlined,
    DashboardModule.managerBudget => Icons.account_balance_wallet_outlined,
    DashboardModule.managerRequests => Icons.folder_open_rounded,
    DashboardModule.managerReports => Icons.bar_chart_rounded,
    DashboardModule.createResourceRequest => Icons.add_shopping_cart_rounded,
    DashboardModule.myResourceRequests => Icons.inventory_2_outlined,
  };

  String get route => switch (this) {
    DashboardModule.createTicket => '/tickets/new',
    DashboardModule.myTickets => '/tickets/my',
    DashboardModule.pendingTickets => '/tickets/pending',
    DashboardModule.departmentTickets => '/tickets/department',
    DashboardModule.departments => '/departments',
    DashboardModule.createUser => '/admin/users/new',
    DashboardModule.userManagement => '/admin/users',
    DashboardModule.managerApprovals => '/gerente/aprobaciones',
    DashboardModule.managerBudget => '/gerente/presupuesto',
    DashboardModule.managerRequests => '/gerente/solicitudes',
    DashboardModule.managerReports => '/gerente/reportes',
    DashboardModule.createResourceRequest => '/resource-requests/new',
    DashboardModule.myResourceRequests => '/resource-requests/my',
  };
}
