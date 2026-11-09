import 'package:centrix/features/departments/models/department_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consulta departamentos con Bearer y lee departmentId', () async {
    String? authorization;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          authorization = options.headers['Authorization'] as String?;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Departamentos obtenidos exitosamente',
                'data': [
                  {
                    'departmentId': 'dep-1',
                    'name': 'Soporte TI',
                    'description': 'Atención a equipos',
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final departments = await DepartmentModel(client: dio).fetchAll('jwt-test');

    expect(authorization, 'Bearer jwt-test');
    expect(departments.single.departmentId, 'dep-1');
    expect(departments.single.name, 'Soporte TI');
  });
}
