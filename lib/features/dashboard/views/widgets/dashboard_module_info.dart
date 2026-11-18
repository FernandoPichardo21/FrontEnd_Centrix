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
    DashboardModule.managerApprovals => 'Aprobaciones',
    DashboardModule.managerBudget => 'Presupuesto',
    DashboardModule.managerRequests => 'Solicitudes del departamento',
    DashboardModule.managerReports => 'Reportes',
  };
  String get description => switch (this) {
    DashboardModule.createTicket => 'Reporta una nueva incidencia',
    DashboardModule.myTickets => 'Seguimiento de tus incidencias',
    DashboardModule.pendingTickets => 'Revisa lo que necesita atención',
    DashboardModule.departmentTickets => 'Incidencias de tu departamento',
    DashboardModule.departments => 'Conoce a las áreas de tu equipo',
    DashboardModule.createUser => 'Agrega una cuenta al equipo',
    DashboardModule.managerApprovals => 'Revisa solicitudes · Vista previa',
    DashboardModule.managerBudget => 'Recursos del área · Vista previa',
    DashboardModule.managerRequests => 'Movimientos del equipo · Vista previa',
    DashboardModule.managerReports => 'Resultados del área · Vista previa',
  };
  IconData get icon => switch (this) {
    DashboardModule.createTicket => Icons.add_rounded,
    DashboardModule.myTickets => Icons.confirmation_number_outlined,
    DashboardModule.pendingTickets => Icons.assignment_outlined,
    DashboardModule.departmentTickets => Icons.view_list_outlined,
    DashboardModule.departments => Icons.apartment_rounded,
    DashboardModule.createUser => Icons.person_add_alt_1_rounded,
    DashboardModule.managerApprovals => Icons.fact_check_outlined,
    DashboardModule.managerBudget => Icons.account_balance_wallet_outlined,
    DashboardModule.managerRequests => Icons.folder_open_rounded,
    DashboardModule.managerReports => Icons.bar_chart_rounded,
  };
  String get route => switch (this) {
    DashboardModule.createTicket => '/tickets/new',
    DashboardModule.myTickets => '/tickets/my',
    DashboardModule.pendingTickets => '/tickets/pending',
    DashboardModule.departmentTickets => '/tickets/department',
    DashboardModule.departments => '/departments',
    DashboardModule.createUser => '/admin/users/new',
    DashboardModule.managerApprovals => '/gerente/aprobaciones',
    DashboardModule.managerBudget => '/gerente/presupuesto',
    DashboardModule.managerRequests => '/gerente/solicitudes',
    DashboardModule.managerReports => '/gerente/reportes',
  };
}
