/// Usuario mostrado en el directorio del módulo administrativo.
class AdminUser {
  const AdminUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String phone;
  final String role;
  final DateTime? createdAt;

  /// Convierte el contrato JSON del backend en un objeto de dominio.
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Sin nombre',
      phone: json['tel'] as String? ?? '',
      role: json['role'] as String? ?? 'sin_rol',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
