import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';
import '../data/models/login_request.dart';

/// ViewModel encargado de manejar la lógica de estado y de negocio
/// para la pantalla de inicio de sesión (Login). Al usar [ChangeNotifier],
/// cualquier cambio en el estado notificará a los observadores (UI).
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  /// Realiza la autenticación del usuario enviando el [email] y [password].
  /// Actualiza de forma reactiva los estados de carga ([isLoading]),
  /// de error ([errorMessage]) y de éxito ([isSuccess]).
  Future<void> login(String email, String password) async {
    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor ingresa email y contraseña';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    final request = LoginRequest(email: email, password: password);
    final response = await _authRepository.login(request);

    _isLoading = false;
    if (response.success) {
      _isSuccess = true;
      // TODO: Save response.token securely (e.g., flutter_secure_storage)
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
}
