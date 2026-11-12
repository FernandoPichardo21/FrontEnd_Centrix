class UserRoleOption {
  const UserRoleOption({required this.role, required this.description});
  final String role;
  final String description;
  String get label => switch (role) {
    'administrador' => 'Administrador',
    'gerente' => 'Gerente',
    'soporte_tecnico' => 'Soporte técnico',
    'colaborador' => 'Colaborador',
    _ => description,
  };
  bool get requiresDepartment => role != 'administrador';
  @override
  bool operator ==(Object other) =>
      other is UserRoleOption && other.role == role;
  @override
  int get hashCode => role.hashCode;
  factory UserRoleOption.fromJson(Map<String, dynamic> json) => UserRoleOption(
    role: json['role'] as String,
    description: json['description'] as String,
  );
}
