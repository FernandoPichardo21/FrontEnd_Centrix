class UpdateUserRequest {
  const UpdateUserRequest({
    required this.nombre,
    this.apellidoPat,
    this.apellidoMat,
    this.tel,
    this.role,
    this.departmentId,
  });

  final String nombre;
  final String? apellidoPat;
  final String? apellidoMat;
  final String? tel;
  final String? role;
  final String? departmentId;

  Map<String, dynamic> toJson() => {
    'nombre': nombre.trim(),
    if (apellidoPat != null) 'apellido_pat': apellidoPat!.trim(),
    if (apellidoMat != null) 'apellido_mat': apellidoMat!.trim(),
    if (tel != null) 'tel': tel!.trim(),
    if (role != null) 'role': role!.trim(),
    if (departmentId != null) 'department_id': departmentId,
  };
}

