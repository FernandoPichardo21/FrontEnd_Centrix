import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:centrix_mobile/features/auth/data/models/login_response.dart';
import 'package:centrix_mobile/features/auth/data/models/user_model.dart';
import 'package:centrix_mobile/features/auth/view/login_screen.dart';
import 'package:centrix_mobile/features/auth/viewmodel/login_viewmodel.dart';

// Importa el mock generado de tu AuthRepository
import 'login_screen_test.mocks.dart';

void main() {
  group('QA Integration Tests - Login & Routing', () {
    late MockAuthRepository mockRepository;
    late LoginViewModel viewModel;

    setUp(() {
      // Se instancian dependencias limpias antes de cada prueba
      mockRepository = MockAuthRepository();
      viewModel = LoginViewModel(mockRepository);
    });

    /// Función auxiliar para montar el Widget en un entorno de pruebas
    Widget buildTestApp() {
      return MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: viewModel,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets(
        'Prueba Positiva: Login exitoso y redirección a panel de Gerente',
        (WidgetTester tester) async {
      // ==========================================
      // 1. ARRANGE (Preparar)
      // ==========================================
      // Preparamos los datos que queremos que el mock devuelva.
      // Simulamos que Supabase/Backend responde exitosamente y que el usuario es 'gerente'.
      final mockGerente = UserModel(
        id: '123',
        email: 'gerente@centrix.com',
        fullName: 'Carlos Gerente',
        role: 'gerente', // El rol clave que dictará el enrutamiento visual
        tel: '555-0000',
      );

      // Configuramos el mock de Mockito para interceptar la llamada
      when(mockRepository.login(any)).thenAnswer(
        (_) async => LoginResponse(
          success: true,
          message: 'Autenticación exitosa',
          token: 'fake_jwt_token',
          user: mockGerente,
        ),
      );

      // Construimos e inflamos nuestra aplicación en el entorno de pruebas
      await tester.pumpWidget(buildTestApp());

      // ==========================================
      // 2. ACT (Actuar)
      // ==========================================
      // Simulamos al usuario interactuando con los campos de texto
      // (Buscamos los campos por su tipo en el LoginScreen)
      final textFields = find.byType(TextField);
      await tester.enterText(
          textFields.at(0), 'gerente@centrix.com'); // Campo de Email
      await tester.enterText(
          textFields.at(1), 'password123'); // Campo de Contraseña

      // Simulamos el tap en el botón de Login (en nuestra app se llama 'Login' en lugar de 'Ingresar')
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);

      // Le pedimos al framework que procese todos los micro-tasks y animaciones
      // (espera a que terminen las peticiones asíncronas y transiciones de pantalla)
      await tester.pumpAndSettle();

      // ==========================================
      // 3. ASSERT (Afirmar/Comprobar)
      // ==========================================
      // Validamos que la pantalla de Login ya NO esté visible (al menos su botón)
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);

      // Validamos que el sistema haya ruteado al usuario correctamente
      // visualizando un Widget o texto exclusivo del dashboard del gerente.
      expect(find.text('Panel de gerente'), findsOneWidget);
    });

    testWidgets(
        'Prueba Negativa: Login fallido por credenciales inválidas (Error 401)',
        (WidgetTester tester) async {
      // ==========================================
      // 1. ARRANGE (Preparar)
      // ==========================================
      const errorMessage = 'Credenciales inválidas';

      // Configuramos el mock para simular que Supabase/Backend rechaza el login
      when(mockRepository.login(any)).thenAnswer(
        (_) async => LoginResponse(
          success: false,
          message: errorMessage,
        ),
      );

      await tester.pumpWidget(buildTestApp());

      // ==========================================
      // 2. ACT (Actuar)
      // ==========================================
      // Ingresamos datos incorrectos
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'hacker@centrix.com');
      await tester.enterText(textFields.at(1), 'clave_falsa');

      // Presionamos el botón
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);

      await tester.pumpAndSettle();

      // ==========================================
      // 3. ASSERT (Afirmar/Comprobar)
      // ==========================================
      // Verificamos que el sistema NO haya navegado, el botón de login debe seguir presente
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

      // Comprobamos que aparezca el mensaje de error visual en pantalla
      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
