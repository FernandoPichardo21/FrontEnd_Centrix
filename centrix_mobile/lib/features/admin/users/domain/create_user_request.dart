class CreateUserRequest {
  const CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    required this.phone,
  });

  final String email;
  final String password;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String phone;

  Map<String, dynamic> toBackendJson() {
    return {
      'email': email,
      'password': password,
      'nombre': firstName,
      'apellido_pat': paternalLastName,
      'apellido_mat': maternalLastName,
      'tel': phone,
    };
  }
}
