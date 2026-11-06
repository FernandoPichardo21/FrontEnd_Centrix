class CreateUserRequest {
  const CreateUserRequest({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellidoPat,
    this.apellidoMat,
    this.telefono,
  });

  final String email;
  final String password;
  final String nombre;
  final String apellidoPat;
  final String? apellidoMat;
  final String? telefono;

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
    'nombre': nombre.trim(),
    'apellido_pat': apellidoPat.trim(),
    if (apellidoMat != null && apellidoMat!.trim().isNotEmpty)
      'apellido_mat': apellidoMat!.trim(),
    if (telefono != null && telefono!.trim().isNotEmpty)
      'tel': telefono!.trim(),
  };
}
