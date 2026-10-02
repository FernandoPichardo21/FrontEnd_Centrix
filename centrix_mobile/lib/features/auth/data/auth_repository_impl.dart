import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_repository.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.client});

  final http.Client client;
  final String baseUrl = 'http://localhost:3000/api/auth';

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonDecode(response.body));
      } else {
        // Handle non-200 responses
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse(
          success: false,
          message: body['message'] ?? 'Error de servidor (${response.statusCode})',
        );
      }
    } on Object catch (e) {
      return LoginResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }
}
