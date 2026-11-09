import 'package:centrix/features/admin_users/models/create_user_request.dart';
import 'package:centrix/features/admin_users/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea un usuario con Bearer y los campos del backend', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: {
                'success': true,
                'message': 'Usuario creado correctamente',
                'data': {'id': 'user-2'},
              },
            ),
          );
        },
      ),
    );

    final created = await UserModel(client: dio).create(
      const CreateUserRequest(
        email: ' nueva@empresa.com ',
        password: 'claveSegura123',
        nombre: ' Ana ',
        apellidoPat: ' López ',
        apellidoMat: ' García ',
      ),
      'jwt-admin',
    );

    expect(created.id, 'user-2');
    expect(sentRequest?.method, 'POST');
    expect(sentRequest?.path, '/api/admin/users');
    expect(sentRequest?.headers['Authorization'], 'Bearer jwt-admin');
    expect(sentRequest?.data, {
      'email': 'nueva@empresa.com',
      'password': 'claveSegura123',
      'nombre': 'Ana',
      'apellido_pat': 'López',
      'apellido_mat': 'García',
    });
  });
}
