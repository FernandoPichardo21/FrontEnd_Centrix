class UserListItem {
  const UserListItem({
    required this.id,
    required this.nombre,
    this.apellidoPat,
    this.apellidoMat,
    required this.fullName,
    required this.email,
    this.tel,
    this.departmentId,
    required this.role,
    this.roles = const [],
  });

  final String id;
  final String nombre;
  final String? apellidoPat;
  final String? apellidoMat;
  final String fullName;
  final String email;
  final String? tel;
  final String? departmentId;
  final String role;
  final List<String> roles;

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    final parts = [
      nombre,
      apellidoPat,
      apellidoMat,
    ].whereType<String>().where((s) => s.trim().isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    return email;
  }

  String get initials {
    final names = displayName
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (names.isEmpty) return 'U';
    if (names.length == 1) {
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  String get roleLabel => switch (role.toLowerCase().trim()) {
    'administrador' => 'Administrador',
    'gerente' => 'Gerente',
    'soporte_tecnico' => 'Soporte técnico',
    'colaborador' => 'Colaborador',
    _ => role,
  };

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final rolesList = rolesRaw is List
        ? rolesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return UserListItem(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidoPat: json['apellido_pat'] as String?,
      apellidoMat: json['apellido_mat'] as String?,
      fullName:
          json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      tel: json['tel'] as String?,
      departmentId:
          json['departmentId'] as String? ?? json['department_id'] as String?,
      role:
          json['role'] as String? ??
          (rolesList.isNotEmpty ? rolesList.first : 'colaborador'),
      roles: rolesList,
    );
  }
}
