import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  const LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    UserModel? userModel;
    if (data is Map<String, dynamic> && data['user'] != null) {
      userModel = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }

    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: userModel,
      token: data is Map<String, dynamic> ? data['token'] as String? : null,
    );
  }
}
