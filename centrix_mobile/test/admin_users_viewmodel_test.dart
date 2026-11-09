import 'dart:convert';
import 'package:centrix_mobile/features/admin/users/data/http_admin_user_repository.dart';
import 'package:centrix_mobile/features/admin/users/domain/admin_user_repository.dart';
import 'package:centrix_mobile/features/admin/users/domain/admin_user.dart';
import 'package:centrix_mobile/features/admin/users/domain/create_user_request.dart';
import 'package:centrix_mobile/features/admin/users/viewmodel/admin_users_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const request = CreateUserRequest(
  email: 'usuario@centrix.demo',
  password: 'Password123',
  firstName: 'Miguel',
  paternalLastName: 'Durazno',
  maternalLastName: 'Martínez',
  phone: '4420000000',
);

void main() {
  test('mapea los campos al contrato actual del backend', () {
    expect(request.toBackendJson(), {
      'email': 'usuario@centrix.demo',
      'password': 'Password123',
      'nombre': 'Miguel',
      'apellido_pat': 'Durazno',
      'apellido_mat': 'Martínez',
      'tel': '4420000000',
    });
  });

  test('envía POST de creación con el JWT del backend', () async {
    final client = MockClient((http.Request httpRequest) async {
      expect(httpRequest.method, 'POST');
      expect(
          httpRequest.url.toString(), 'http://localhost:3000/api/admin/users');
      expect(httpRequest.headers['authorization'], 'Bearer backend-jwt');
      expect(jsonDecode(httpRequest.body), request.toBackendJson());
      return http.Response(
        jsonEncode(
            {'success': true, 'message': 'Usuario creado correctamente'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = HttpAdminUserRepository(
      client: client,
      baseUrl: 'http://localhost:3000',
      token: 'backend-jwt',
    );

    await repository.create(request);
  });

  test('viewmodel expone confirmación al crear', () async {
    final viewModel = AdminUsersViewModel(_SuccessfulRepository());

    final result = await viewModel.createUser(request);

    expect(result, isTrue);
    expect(viewModel.successMessage, 'Usuario creado correctamente');
    expect(viewModel.errorMessage, isNull);
  });
}

class _SuccessfulRepository implements AdminUserRepository {
  @override
  Future<List<AdminUser>> fetchAll() async => const [];

  @override
  Future<void> create(CreateUserRequest request) async {}
}
