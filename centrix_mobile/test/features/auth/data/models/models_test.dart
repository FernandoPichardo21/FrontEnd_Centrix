import 'package:flutter_test/flutter_test.dart';

import 'package:centrix_mobile/features/auth/data/models/login_request.dart';
import 'package:centrix_mobile/features/auth/data/models/login_response.dart';
import 'package:centrix_mobile/features/auth/data/models/user_model.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Pruebas unitarias de los Modelos de Datos
  // Se verifica la serialización / deserialización de JSON sin dependencias.
  // ─────────────────────────────────────────────────────────────────────────

  // ── LoginRequest ──────────────────────────────────────────────────────────
  group('LoginRequest –', () {
    test('toJson() produce el mapa correcto', () {
      const email = 'usuario@centrix.com';
      const password = 'P@ssw0rd!';

      final request = LoginRequest(email: email, password: password);
      final json = request.toJson();

      expect(json['email'], equals(email));
      expect(json['password'], equals(password));
      expect(json.length, equals(2), reason: 'Solo email y password');
    });

    test('toJson() no incluye campos nulos o extra', () {
      final request = LoginRequest(email: 'a@b.com', password: '123456');
      final json = request.toJson();

      expect(json.containsKey('token'), isFalse);
      expect(json.containsKey('user'), isFalse);
    });
  });

  // ── LoginResponse ─────────────────────────────────────────────────────────
  group('LoginResponse –', () {
    group('fromJson() respuesta exitosa', () {
      test('parsea correctamente una respuesta de login exitoso con token',
          () {
        final json = {
          'success': true,
          'message': 'Autenticado correctamente',
          'token': 'eyJhbGciOiJIUzI1NiJ9.test',
          'data': {
            'user': {
              'id': 1,
              'email': 'usuario@centrix.com',
              'name': 'Juan Pérez',
            },
          },
        };

        final response = LoginResponse.fromJson(json);

        expect(response.success, isTrue);
        expect(response.message, equals('Autenticado correctamente'));
        expect(response.token, equals('eyJhbGciOiJIUzI1NiJ9.test'));
        expect(response.user, isNotNull);
        expect(response.user!.email, equals('usuario@centrix.com'));
      });

      test('parsea respuesta sin campo token', () {
        final json = {
          'success': true,
          'message': 'ok',
        };

        final response = LoginResponse.fromJson(json);
        expect(response.token, isNull);
        expect(response.user, isNull);
      });
    });

    group('fromJson() respuesta fallida', () {
      test('parsea correctamente una respuesta de error del servidor', () {
        final json = {
          'success': false,
          'message': 'Credenciales incorrectas',
        };

        final response = LoginResponse.fromJson(json);

        expect(response.success, isFalse);
        expect(response.message, equals('Credenciales incorrectas'));
        expect(response.token, isNull);
        expect(response.user, isNull);
      });

      test('maneja JSON malformado con valores por defecto', () {
        // El servidor podría no incluir todos los campos en casos de error
        final json = <String, dynamic>{};

        final response = LoginResponse.fromJson(json);

        expect(response.success, isFalse); // Valor por defecto
        expect(response.message, equals('')); // Valor por defecto
      });
    });
  });
}
