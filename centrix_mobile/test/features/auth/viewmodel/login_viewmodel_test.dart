import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:centrix_mobile/features/auth/data/auth_repository.dart';
import 'package:centrix_mobile/features/auth/data/models/login_request.dart';
import 'package:centrix_mobile/features/auth/data/models/login_response.dart';
import 'package:centrix_mobile/features/auth/viewmodel/login_viewmodel.dart';

// Genera el mock automáticamente con: dart run build_runner build
@GenerateMocks([AuthRepository])
import 'login_viewmodel_test.mocks.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Pruebas unitarias de LoginViewModel
  // Se prueba la lógica de negocio en aislamiento completo del repositorio.
  // ─────────────────────────────────────────────────────────────────────────
  group('LoginViewModel –', () {
    late MockAuthRepository mockRepository;
    late LoginViewModel viewModel;

    setUp(() {
      mockRepository = MockAuthRepository();
      viewModel = LoginViewModel(mockRepository);
    });

    // ── Estado inicial ──────────────────────────────────────────────────────
    group('estado inicial', () {
      test('isLoading es false', () {
        expect(viewModel.isLoading, isFalse);
      });

      test('errorMessage es null', () {
        expect(viewModel.errorMessage, isNull);
      });

      test('isSuccess es false', () {
        expect(viewModel.isSuccess, isFalse);
      });
    });

    // ── Validación de campos vacíos ─────────────────────────────────────────
    group('login() con campos vacíos', () {
      test('establece errorMessage cuando email está vacío', () async {
        await viewModel.login('', 'password123');

        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isLoading, isFalse);
        verifyNever(mockRepository.login(any));
      });

      test('establece errorMessage cuando password está vacío', () async {
        await viewModel.login('test@centrix.com', '');

        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isLoading, isFalse);
        verifyNever(mockRepository.login(any));
      });

      test('no llama al repositorio con credenciales vacías', () async {
        await viewModel.login('', '');
        verifyNever(mockRepository.login(any));
      });
    });

    // ── Flujo de login exitoso ──────────────────────────────────────────────
    group('login() con credenciales correctas', () {
      const testEmail = 'usuario@centrix.com';
      const testPassword = 'password_seguro';

      setUp(() {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(
            success: true,
            message: 'Autenticación exitosa',
            token: 'jwt_token_centrix_123',
          ),
        );
      });

      test('isLoading es true durante la petición', () async {
        bool loadingCapturado = false;

        viewModel.addListener(() {
          if (viewModel.isLoading) loadingCapturado = true;
        });

        await viewModel.login(testEmail, testPassword);

        expect(loadingCapturado, isTrue,
            reason: 'isLoading debe ser true durante la petición HTTP');
      });

      test('isSuccess es true al recibir respuesta exitosa', () async {
        await viewModel.login(testEmail, testPassword);

        expect(viewModel.isSuccess, isTrue);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.isLoading, isFalse);
      });

      test('llama al repositorio con los datos correctos', () async {
        await viewModel.login(testEmail, testPassword);

        final captured = verify(mockRepository.login(captureAny)).captured;
        final request = captured.first as LoginRequest;

        expect(request.email, equals(testEmail));
        expect(request.password, equals(testPassword));
      });
    });

    // ── Flujo de login fallido ──────────────────────────────────────────────
    group('login() con credenciales incorrectas', () {
      const errorMsg = 'Credenciales inválidas';

      setUp(() {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(
            success: false,
            message: errorMsg,
          ),
        );
      });

      test('isSuccess es false y errorMessage está poblado', () async {
        await viewModel.login('mal@email.com', 'mal_pass');

        expect(viewModel.isSuccess, isFalse);
        expect(viewModel.errorMessage, equals(errorMsg));
        expect(viewModel.isLoading, isFalse);
      });
    });

    // ── Manejo de errores de red ────────────────────────────────────────────
    group('login() con error de conexión', () {
      setUp(() {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(
            success: false,
            message: 'Error de conexión: SocketException',
          ),
        );
      });

      test('muestra mensaje de error de red', () async {
        await viewModel.login('usuario@centrix.com', 'password');

        expect(viewModel.isSuccess, isFalse);
        expect(viewModel.errorMessage, contains('Error de conexión'));
      });
    });

    // ── Notificaciones a la UI ──────────────────────────────────────────────
    group('notifyListeners()', () {
      test('notifica al menos dos veces (inicio y fin de loading)', () async {
        when(mockRepository.login(any)).thenAnswer(
          (_) async => LoginResponse(success: true, message: 'ok'),
        );

        int notificaciones = 0;
        viewModel.addListener(() => notificaciones++);

        await viewModel.login('a@b.com', '12345678');

        // Mínimo: 1 notif cuando isLoading = true, 1 cuando isLoading = false
        expect(notificaciones, greaterThanOrEqualTo(2));
      });
    });
  });
}
