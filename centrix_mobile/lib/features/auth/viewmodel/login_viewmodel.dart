import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';
import '../data/models/login_request.dart';
import '../data/models/user_model.dart';

/// Mantiene el estado del inicio de sesión sin depender de la interfaz.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  UserModel? _authenticatedUser;
  UserModel? get authenticatedUser => _authenticatedUser;

  String? _token;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor ingresa email y contraseña';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    _authenticatedUser = null;
    _token = null;
    notifyListeners();

    final request = LoginRequest(email: email, password: password);
    final response = await _authRepository.login(request);

    _isLoading = false;
    if (response.success && response.user != null) {
      _isSuccess = true;
      _authenticatedUser = response.user;
      _token = response.token;
    } else {
      _errorMessage = response.success
          ? 'No se recibieron los datos del usuario'
          : response.message;
    }
    notifyListeners();
    return _isSuccess;
  }

  void logout() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    _authenticatedUser = null;
    _token = null;
    notifyListeners();
  }
}
