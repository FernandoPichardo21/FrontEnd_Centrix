import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../departments/models/department_model.dart';
import '../../tickets/models/ticket.dart';
import '../../tickets/models/ticket_model.dart';
import '../../auth/models/auth_user.dart';
import '../models/dashboard_module.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(
    this.user, {
    TicketModel? ticketModel,
    DepartmentModel? departmentModel,
  }) : _ticketModel = ticketModel ?? TicketModel(),
       _departmentModel = departmentModel ?? DepartmentModel();

  final AuthUser user;
  final TicketModel _ticketModel;
  final DepartmentModel _departmentModel;
  List<Ticket>? _myTickets;
  List<Ticket>? _pending;
  int? _departmentCount;
  bool _isLoading = false;
  bool _disposed = false;
  bool _requiresLogin = false;
  String? _loadError;
  bool get isLoading => _isLoading;
  bool get requiresLogin => _requiresLogin;
  String? get loadError => _loadError;
  List<Ticket> get pending => List.unmodifiable(_pending ?? const <Ticket>[]);
  String get firstName => displayName.split(RegExp(r'\s+')).first;
  String get initials => displayName
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0])
      .join()
      .toUpperCase();
  String get primaryRoleLabel => _labelForRole(user.role.toLowerCase().trim());
  bool get hasTicketData => _myTickets?.isNotEmpty ?? false;
  double get resolutionRate => !hasTicketData
      ? 0
      : _myTickets!
                .where(
                  (ticket) => [
                    'resuelto',
                    'cerrado',
                  ].contains(ticket.status.toLowerCase().trim()),
                )
                .length /
            _myTickets!.length;
  List<Ticket> get recentActivity {
    final byId = <String, Ticket>{
      for (final ticket in [...?_pending, ...?_myTickets])
        ticket.ticketId: ticket,
    };
    final items = byId.values.toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
    return items.take(6).toList();
  }

  DashboardModule get primaryModule => user.canCreateTicket
      ? DashboardModule.createTicket
      : DashboardModule.myTickets;
  List<DashboardModule> get homeModules {
    final preferred = user.canViewManager
        ? [
            DashboardModule.managerApprovals,
            DashboardModule.managerBudget,
            DashboardModule.managerRequests,
            DashboardModule.managerReports,
          ]
        : [
            DashboardModule.myTickets,
            DashboardModule.pendingTickets,
            DashboardModule.departments,
            DashboardModule.createUser,
          ];
    return preferred
        .where((module) => modules.contains(module) && module != primaryModule)
        .take(4)
        .toList();
  }

  String badge(DashboardModule module) {
    String count(int? value) => value == null
        ? '—'
        : value > 99
        ? '99+'
        : value.toString().padLeft(2, '0');
    return switch (module) {
      DashboardModule.myTickets => count(_myTickets?.length),
      DashboardModule.pendingTickets => count(_pending?.length),
      DashboardModule.departments => count(_departmentCount),
      DashboardModule.createTicket || DashboardModule.createUser => '+',
      DashboardModule.managerApprovals ||
      DashboardModule.managerBudget ||
      DashboardModule.managerRequests ||
      DashboardModule.managerReports => 'Demo',
      DashboardModule.departmentTickets => '↗',
    };
  }

  Future<void> load(String token) async {
    if (_disposed || _isLoading) return;
    _isLoading = true;
    _loadError = null;
    _requiresLogin = false;
    notifyListeners();
    Future<void> fetch(Future<void> Function() action) async {
      try {
        await action();
      } on ApiException catch (error) {
        _loadError = 'No se pudo actualizar toda la actividad.';
        if (error.statusCode == 401) _requiresLogin = true;
      } catch (_) {
        _loadError = 'No se pudo actualizar toda la actividad.';
      }
    }

    await Future.wait([
      fetch(() async {
        _myTickets = await _ticketModel.getMyTickets(token);
      }),
      fetch(() async {
        _departmentCount = (await _departmentModel.fetchAll(token)).length;
      }),
      if (user.canManageTickets)
        fetch(() async {
          _pending = await _ticketModel.getPendingTickets(token);
        }),
    ]);
    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

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
    final managerModules = [
      DashboardModule.managerApprovals,
      DashboardModule.managerBudget,
      DashboardModule.managerRequests,
      DashboardModule.managerReports,
    ];
    return [
      if (user.canViewManager) ...managerModules,
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
