/// Utilidad de validación de formularios — función pura sin dependencias de UI.
///
/// Todas las funciones en este archivo son puras: dado el mismo input,
/// siempre devuelven el mismo output y no producen efectos secundarios.
/// Esto las hace altamente testables y reutilizables en cualquier capa.
library form_validator;

// ─────────────────────────────────────────────────────────────────────────────
// Resultado de validación
// ─────────────────────────────────────────────────────────────────────────────

/// Resultado inmutable de una validación de formulario.
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// `true` si todos los campos son válidos.
  final bool isValid;

  /// Mapa de campo → mensaje de error (vacío si no hay errores).
  final Map<String, String> errors;

  /// Devuelve el error de un campo específico o `null` si no hay error.
  String? errorFor(String field) => errors[field];

  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}

// ─────────────────────────────────────────────────────────────────────────────
// FormValidator
// ─────────────────────────────────────────────────────────────────────────────

/// Colección de funciones puras para validar el formulario de login.
///
/// Uso básico:
/// ```dart
/// final result = FormValidator.validateLoginForm(
///   email: 'user@example.com',
///   password: 'MyPass1!',
/// );
/// if (!result.isValid) print(result.errors);
/// ```
abstract final class FormValidator {
  // ── Constantes ─────────────────────────────────────────────────────────────

  static const int _minPasswordLength = 8;

  /// Expresión regular mínima de email (RFC 5322 simplificado).
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  // ── Validadores individuales ────────────────────────────────────────────────

  /// Valida que [email] tenga formato correcto.
  ///
  /// Reglas:
  /// - No puede estar vacío.
  /// - Debe coincidir con el patrón `local@dominio.tld`.
  ///
  /// Devuelve `null` si es válido, o un mensaje de error en caso contrario.
  static String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'El email es obligatorio';
    if (!_emailRegex.hasMatch(trimmed)) return 'Formato de email inválido';
    return null;
  }

  /// Valida que [password] cumpla con los requisitos mínimos de seguridad.
  ///
  /// Reglas:
  /// - No puede estar vacío.
  /// - Mínimo [_minPasswordLength] caracteres.
  ///
  /// Devuelve `null` si es válido, o un mensaje de error en caso contrario.
  static String? validatePassword(String password) {
    if (password.isEmpty) return 'La contraseña es obligatoria';
    if (password.length < _minPasswordLength) {
      return 'La contraseña debe tener al menos $_minPasswordLength caracteres';
    }
    return null;
  }

  // ── Validador compuesto ─────────────────────────────────────────────────────

  /// Valida el formulario de login completo y devuelve un [ValidationResult].
  ///
  /// Ejecuta todos los validadores individuales y recopila los errores en
  /// un mapa `{campo: mensajeDeError}`.
  ///
  /// Ejemplo:
  /// ```dart
  /// final result = FormValidator.validateLoginForm(
  ///   email: '',
  ///   password: '123',
  /// );
  /// // result.isValid == false
  /// // result.errors == {'email': 'El email es obligatorio',
  /// //                   'password': 'La contraseña debe tener al menos 8 caracteres'}
  /// ```
  static ValidationResult validateLoginForm({
    required String email,
    required String password,
  }) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) errors['password'] = passwordError;

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ── Formateador de errores ──────────────────────────────────────────────────

  /// Combina todos los errores en un único string separado por saltos de línea.
  ///
  /// Útil para mostrar todos los errores como un bloque de texto en la UI.
  static String formatErrors(ValidationResult result) {
    if (result.isValid) return '';
    return result.errors.values.join('\n');
  }
}
