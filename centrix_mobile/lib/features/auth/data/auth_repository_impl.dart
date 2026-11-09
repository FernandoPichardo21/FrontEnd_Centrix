import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_repository.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(body);
      }

      return LoginResponse(
        success: false,
        message: body['message'] as String? ??
            'Error de servidor (${response.statusCode})',
      );
    } on FormatException {
      return const LoginResponse(
        success: false,
        message: 'El backend devolvió una respuesta no válida',
      );
    } catch (_) {
      return const LoginResponse(
        success: false,
        message: 'No fue posible conectar con el backend',
      );
    }
  }
}
