enum UserRole {
  colaborador,
  gerente,
  administrador,
  desconocido;

  factory UserRole.fromBackend(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'colaborador' => UserRole.colaborador,
      'gerente' => UserRole.gerente,
      'administrador' || 'admin' => UserRole.administrador,
      _ => UserRole.desconocido,
    };
  }
}
