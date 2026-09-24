import 'package:flutter/foundation.dart';

/// Resuelve la URL del backend según la plataforma de ejecución.
///
/// `API_BASE_URL` permite reemplazar la dirección sin modificar el código.
class ApiConfig {
  const ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    // En el emulador Android, 10.0.2.2 apunta a la computadora anfitriona.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }
}
