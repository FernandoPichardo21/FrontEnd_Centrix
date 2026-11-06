import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/auth_model.dart';
import '../models/auth_session.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._model);

  final AuthModel _model;
  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _model.login(email.trim(), password);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error al iniciar sesión.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }
}
