import 'package:flutter_test/flutter_test.dart';
import 'package:centrix_mobile/core/utils/form_validator.dart';

// =============================================================================
// Pruebas unitarias de FormValidator
// =============================================================================
// Esta suite prueba la función pura `FormValidator.validateLoginForm()` y
// sus validadores auxiliares, cubriendo los casos del Plan de Pruebas Mínimo
// de la Práctica de CI/CD.
//
// Cómo ejecutar:
//   flutter test test/core/utils/form_validator_test.dart --reporter=expanded
// =============================================================================

void main() {
  // ── validateEmail ──────────────────────────────────────────────────────────
  group('FormValidator.validateEmail –', () {
    group('emails válidos', () {
      final validEmails = [
        'user@example.com',
        'user.name+tag@sub.domain.org',
        'ADMIN@CENTRIX.MX',
        'john.doe@company.io',
      ];

      for (final email in validEmails) {
        test('acepta "$email"', () {
          expect(FormValidator.validateEmail(email), isNull);
        });
      }
    });

    group('emails inválidos', () {
      test('rechaza cadena vacía', () {
        final error = FormValidator.validateEmail('');
        expect(error, isNotNull);
        expect(error, contains('obligatorio'));
      });

      test('rechaza cadena con solo espacios', () {
        final error = FormValidator.validateEmail('   ');
        expect(error, isNotNull);
      });

      test('rechaza email sin "@"', () {
        final error = FormValidator.validateEmail('userexample.com');
        expect(error, isNotNull);
        expect(error, contains('inválido'));
      });

      test('rechaza email sin dominio', () {
        final error = FormValidator.validateEmail('user@');
        expect(error, isNotNull);
      });

      test('rechaza email sin TLD', () {
        final error = FormValidator.validateEmail('user@domain');
        expect(error, isNotNull);
      });

      test('rechaza email con espacios internos', () {
        final error = FormValidator.validateEmail('user @domain.com');
        expect(error, isNotNull);
      });
    });
  });

  // ── validatePassword ───────────────────────────────────────────────────────
  group('FormValidator.validatePassword –', () {
    group('contraseñas válidas', () {
      test('acepta contraseña exactamente de 8 caracteres', () {
        expect(FormValidator.validatePassword('12345678'), isNull);
      });

      test('acepta contraseña de más de 8 caracteres', () {
        expect(FormValidator.validatePassword('MiContraseñaSegura!'), isNull);
      });
    });

    group('contraseñas inválidas', () {
      test('rechaza cadena vacía', () {
        final error = FormValidator.validatePassword('');
        expect(error, isNotNull);
        expect(error, contains('obligatoria'));
      });

      test('rechaza contraseña de 7 caracteres (< mínimo)', () {
        final error = FormValidator.validatePassword('1234567');
        expect(error, isNotNull);
        expect(error, contains('8'));
      });

      test('rechaza contraseña de 1 carácter', () {
        expect(FormValidator.validatePassword('x'), isNotNull);
      });
    });
  });

  // ── validateLoginForm (función pura compuesta) ─────────────────────────────
  group('FormValidator.validateLoginForm –', () {
    test('retorna isValid=true con email y contraseña correctos', () {
      final result = FormValidator.validateLoginForm(
        email: 'admin@centrix.com',
        password: 'Admin1234',
      );

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('retorna isValid=false cuando ambos campos están vacíos', () {
      final result = FormValidator.validateLoginForm(
        email: '',
        password: '',
      );

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('email'), isTrue);
      expect(result.errors.containsKey('password'), isTrue);
    });

    test('retorna error solo de email con contraseña válida', () {
      final result = FormValidator.validateLoginForm(
        email: 'no-es-email',
        password: 'password123',
      );

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('email'), isTrue);
      expect(result.errors.containsKey('password'), isFalse);
    });

    test('retorna error solo de password con email válido', () {
      final result = FormValidator.validateLoginForm(
        email: 'user@centrix.com',
        password: '123',
      );

      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('password'), isTrue);
      expect(result.errors.containsKey('email'), isFalse);
    });

    test('errorFor() devuelve el mensaje del campo correcto', () {
      final result = FormValidator.validateLoginForm(
        email: '',
        password: 'ValidPass1',
      );

      expect(result.errorFor('email'), isNotNull);
      expect(result.errorFor('password'), isNull);
    });

    test('errorFor() devuelve null para campo sin error', () {
      final result = FormValidator.validateLoginForm(
        email: 'ok@centrix.com',
        password: 'ValidPass1',
      );

      expect(result.errorFor('email'), isNull);
      expect(result.errorFor('password'), isNull);
    });

    // ── Casos límite ───────────────────────────────────────────────────────
    group('casos límite', () {
      test('email con espacios al inicio/final se normaliza (trim)', () {
        // El validador hace trim, por lo que este email es válido
        final result = FormValidator.validateLoginForm(
          email: '  admin@centrix.com  ',
          password: 'password123',
        );
        expect(result.isValid, isTrue);
      });

      test('contraseña de exactamente 8 caracteres es válida', () {
        final result = FormValidator.validateLoginForm(
          email: 'user@example.com',
          password: '12345678',
        );
        expect(result.isValid, isTrue);
      });

      test('contraseña de 7 caracteres no es válida', () {
        final result = FormValidator.validateLoginForm(
          email: 'user@example.com',
          password: '1234567',
        );
        expect(result.isValid, isFalse);
        expect(result.errors.containsKey('password'), isTrue);
      });
    });
  });

  // ── formatErrors ──────────────────────────────────────────────────────────
  group('FormValidator.formatErrors –', () {
    test('devuelve cadena vacía cuando el resultado es válido', () {
      final result = FormValidator.validateLoginForm(
        email: 'ok@centrix.com',
        password: 'password123',
      );
      expect(FormValidator.formatErrors(result), isEmpty);
    });

    test('devuelve todos los errores cuando hay múltiples', () {
      final result = FormValidator.validateLoginForm(
        email: '',
        password: '',
      );
      final formatted = FormValidator.formatErrors(result);
      expect(formatted, isNotEmpty);
      // Debe contener texto de ambos errores
      expect(formatted.split('\n').length, equals(2));
    });

    test('devuelve un solo error cuando solo un campo falla', () {
      final result = FormValidator.validateLoginForm(
        email: 'bad-email',
        password: 'password123',
      );
      final formatted = FormValidator.formatErrors(result);
      expect(formatted.split('\n').length, equals(1));
    });
  });
}
