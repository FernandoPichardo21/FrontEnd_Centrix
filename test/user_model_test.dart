import 'package:centrix/features/admin_users/models/create_user_request.dart';
import 'package:centrix/features/admin_users/models/update_user_request.dart';
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
        role: 'gerente',
        departmentId: 'dep-1',
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
      'role': 'gerente',
      'department_id': 'dep-1',
    });
  });

  test('fetchUsers envía query params y token Bearer', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': {
                  'items': [
                    {
                      'id': 'u1',
                      'nombre': 'Carlos',
                      'apellido_pat': 'Ruiz',
                      'email': 'carlos@centrix.com',
                      'role': 'soporte_tecnico',
                      'department_id': 'dep-soporte',
                    }
                  ],
                  'pagination': {
                    'total': 1,
                    'page': 1,
                    'limit': 20,
                    'totalPages': 1,
                  },
                },
              },
            ),
          );
        },
      ),
    );

    final response = await UserModel(client: dio).fetchUsers(
      'jwt-token',
      page: 1,
      limit: 20,
      search: 'carlos',
      role: 'soporte_tecnico',
    );

    expect(sentRequest?.method, 'GET');
    expect(sentRequest?.path, '/api/users');
    expect(sentRequest?.headers['Authorization'], 'Bearer jwt-token');
    expect(sentRequest?.queryParameters['search'], 'carlos');
    expect(sentRequest?.queryParameters['role'], 'soporte_tecnico');
    expect(response.items.length, 1);
    expect(response.items.first.nombre, 'Carlos');
    expect(response.pagination.total, 1);
  });

  test('updateUser envía PUT con datos serializados', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Usuario actualizado correctamente',
              },
            ),
          );
        },
      ),
    );

    await UserModel(client: dio).updateUser(
      'u1',
      const UpdateUserRequest(
        nombre: 'Carlos Modificado',
        role: 'gerente',
        departmentId: 'dep-ventas',
      ),
      'jwt-token',
    );

    expect(sentRequest?.method, 'PUT');
    expect(sentRequest?.path, '/api/users/u1');
    expect(sentRequest?.headers['Authorization'], 'Bearer jwt-token');
    expect(sentRequest?.data, {
      'nombre': 'Carlos Modificado',
      'role': 'gerente',
      'department_id': 'dep-ventas',
    });
  });

  test('deleteUser envía DELETE al endpoint correspondiente', () async {
    RequestOptions? sentRequest;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sentRequest = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Usuario eliminado lógicamente',
              },
            ),
          );
        },
      ),
    );

    await UserModel(client: dio).deleteUser('u1', 'jwt-token');

    expect(sentRequest?.method, 'DELETE');
    expect(sentRequest?.path, '/api/users/u1');
    expect(sentRequest?.headers['Authorization'], 'Bearer jwt-token');
  });
}
