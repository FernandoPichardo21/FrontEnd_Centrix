import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:centrix_mobile/features/auth/data/auth_repository.dart';
import 'package:centrix_mobile/features/auth/data/models/login_response.dart';
import 'package:centrix_mobile/features/auth/view/login_screen.dart';
import 'package:centrix_mobile/features/auth/viewmodel/login_viewmodel.dart';

@GenerateMocks([AuthRepository])
import 'login_screen_test.mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: envuelve el widget en el árbol de providers necesario
// ─────────────────────────────────────────────────────────────────────────────
Widget buildTestApp({required LoginViewModel viewModel}) {
  return MaterialApp(
    home: ChangeNotifierProvider<LoginViewModel>.value(
      value: viewModel,
      child: const LoginScreen(),
    ),
  );
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Pruebas de Widget – LoginScreen
  // Validan que la UI reaccione correctamente a los estados del ViewModel.
  // ─────────────────────────────────────────────────────────────────────────
  group('LoginScreen (Widget Tests) –', () {
    late MockAuthRepository mockRepository;
    late LoginViewModel viewModel;

    setUp(() {
      mockRepository = MockAuthRepository();
      viewModel = LoginViewModel(mockRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    // ── Renderizado inicial ─────────────────────────────────────────────────
    group('renderizado inicial', () {
      testWidgets('muestra el campo Email', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('muestra el campo Password', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('muestra el botón Login habilitado', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        final button = find.widgetWithText(ElevatedButton, 'Login');
        expect(button, findsOneWidget);

        final elevatedButton = tester.widget<ElevatedButton>(button);
        expect(elevatedButton.onPressed, isNotNull);
      });

      testWidgets('no muestra mensajes de error al inicio', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    // ── Interacción con formulario ──────────────────────────────────────────
    group('interacción de formulario', () {
      testWidgets('permite ingresar texto en campo Email', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        final emailField = find.widgetWithText(TextField, 'ejemplo@correo.com');
        await tester.enterText(emailField, 'test@centrix.com');
        await tester.pump();

        expect(find.text('test@centrix.com'), findsOneWidget);
      });

      testWidgets('el campo Password oculta el texto', (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        // Buscamos el TextField que tiene obscureText = true
        final textFields = tester.widgetList<TextField>(find.byType(TextField));
        final passwordField = textFields.firstWhere((f) => f.obscureText);

        expect(passwordField.obscureText, isTrue);
      });
    });

    // ── Estado de carga ─────────────────────────────────────────────────────
    group('estado de carga', () {
      testWidgets('muestra CircularProgressIndicator mientras isLoading = true',
          (tester) async {
        // Simula un delay para capturar el estado de loading
        when(mockRepository.login(any)).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(seconds: 1));
            return LoginResponse(success: true, message: 'ok');
          },
        );

        await tester.pumpWidget(buildTestApp(viewModel: viewModel));
        await tester.enterText(
            find.widgetWithText(TextField, 'ejemplo@correo.com'),
            'user@centrix.com');
        await tester.enterText(
            find.byType(TextField).at(1), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump(); // Primer frame tras el tap

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Login'), findsNothing); // El texto desaparece

        // Finaliza la operación asíncrona
        await tester.pumpAndSettle();
      });

      testWidgets('deshabilita el botón mientras isLoading = true',
          (tester) async {
        when(mockRepository.login(any)).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(seconds: 1));
            return LoginResponse(success: true, message: 'ok');
          },
        );

        await tester.pumpWidget(buildTestApp(viewModel: viewModel));
        await tester.enterText(
            find.widgetWithText(TextField, 'ejemplo@correo.com'),
            'user@centrix.com');
        await tester.enterText(find.byType(TextField).at(1), 'pass');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
            find.byType(ElevatedButton));
        expect(button.onPressed, isNull); // Deshabilitado

        await tester.pumpAndSettle();
      });
    });

    // ── Mensajes de error ───────────────────────────────────────────────────
    group('mensajes de error', () {
      testWidgets('muestra error cuando login falla', (tester) async {
        const errorMessage = 'Credenciales inválidas';
        when(mockRepository.login(any)).thenAnswer(
          (_) async =>
              LoginResponse(success: false, message: errorMessage),
        );

        await tester.pumpWidget(buildTestApp(viewModel: viewModel));
        await tester.enterText(
            find.widgetWithText(TextField, 'ejemplo@correo.com'),
            'bad@email.com');
        await tester.enterText(find.byType(TextField).at(1), 'wrongpass');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text(errorMessage), findsOneWidget);
      });

      testWidgets(
          'muestra error de validación con campos vacíos sin llamar al backend',
          (tester) async {
        await tester.pumpWidget(buildTestApp(viewModel: viewModel));

        // Presionar Login sin llenar campos
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Por favor'), findsOneWidget);
        verifyNever(mockRepository.login(any));
      });
    });

    // ── Mensaje de éxito ────────────────────────────────────────────────────
    group('mensaje de éxito', () {
      testWidgets('muestra mensaje de éxito cuando login es correcto',
          (tester) async {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(
              success: true, message: 'ok', token: 'token_xyz'),
        );

        await tester.pumpWidget(buildTestApp(viewModel: viewModel));
        await tester.enterText(
            find.widgetWithText(TextField, 'ejemplo@correo.com'),
            'admin@centrix.com');
        await tester.enterText(find.byType(TextField).at(1), 'admin123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.textContaining('exitoso'), findsOneWidget);
      });
    });
  });
}
