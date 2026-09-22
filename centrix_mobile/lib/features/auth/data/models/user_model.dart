class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String tel;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.tel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      tel: json['tel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'tel': tel,
    };
  }
}
