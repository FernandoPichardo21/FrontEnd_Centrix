import 'package:centrix_mobile/features/auth/data/models/login_response.dart';
import 'package:centrix_mobile/features/auth/data/models/user_model.dart';
import 'package:centrix_mobile/features/dashboard/view/dashboard_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserModel userWithRole(String role) => UserModel(
        id: 'user-id',
        email: 'usuario@centrix.com',
        fullName: 'Usuario Centrix',
        role: role,
        tel: '5555555555',
      );

  Future<void> renderDashboard(WidgetTester tester, String role) async {
    await tester.pumpWidget(
      MaterialApp(home: DashboardRouter(user: userWithRole(role))),
    );
  }

  testWidgets('redirige al dashboard de colaborador', (tester) async {
    await renderDashboard(tester, 'colaborador');

    expect(find.text('Panel de colaborador'), findsOneWidget);
    expect(find.text('Mis tickets'), findsOneWidget);
  });

  testWidgets('redirige al dashboard de gerente', (tester) async {
    await renderDashboard(tester, 'gerente');

    expect(find.text('Panel de gerente'), findsOneWidget);
    expect(find.text('Tickets pendientes'), findsOneWidget);
  });

  testWidgets('redirige al dashboard de administrador', (tester) async {
    await renderDashboard(tester, 'administrador');

    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
  });

  testWidgets('muestra un estado seguro para un rol desconocido',
      (tester) async {
    await renderDashboard(tester, 'rol_inexistente');

    expect(find.textContaining('rol no reconocido'), findsOneWidget);
  });

  test('extrae usuario y token desde data en la respuesta de login', () {
    final response = LoginResponse.fromJson({
      'success': true,
      'message': 'Inicio de sesión exitoso',
      'data': {
        'user': userWithRole('colaborador').toJson(),
        'token': 'jwt-token',
      },
    });

    expect(response.user?.role, 'colaborador');
    expect(response.token, 'jwt-token');
  });
}
