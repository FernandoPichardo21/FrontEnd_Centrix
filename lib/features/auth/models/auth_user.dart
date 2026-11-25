class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.roles,
    this.phone,
    this.departmentId,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final List<String> roles;
  final String? phone;
  final String? departmentId;

  bool hasAnyRole(Iterable<String> allowedRoles) {
    final currentRoles = {
      role.toLowerCase().trim(),
      ...roles.map((value) => value.toLowerCase().trim()),
    };
    return allowedRoles.any(
      (value) => currentRoles.contains(value.toLowerCase().trim()),
    );
  }

  bool get canCreateTicket =>
      hasAnyRole(const ['colaborador', 'gerente', 'administrador']);

  bool get canViewDepartmentTickets =>
      hasAnyRole(const ['gerente', 'administrador']);

  bool get canManageTickets => canViewDepartmentTickets;

  bool get canCreateUser => hasAnyRole(const ['administrador']);
  bool get canViewUsers => hasAnyRole(const ['administrador']);
  bool get canViewManager => hasAnyRole(const ['gerente', 'administrador']);
  bool get canCreateResourceRequest => hasAnyRole(const [
    'colaborador',
    'gerente',
    'administrador',
    'soporte_tecnico',
  ]);

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
      phone: json['tel'] as String?,
      departmentId: (json['department_id'] ?? json['departmentId']) as String?,
    );
  }
}
