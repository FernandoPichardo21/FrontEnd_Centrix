import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    UserModel? userModel;
    if (json['data'] != null && json['data']['user'] != null) {
      userModel = UserModel.fromJson(json['data']['user']);
    }

    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: userModel,
      token: json['token'],
    );
  }
}
