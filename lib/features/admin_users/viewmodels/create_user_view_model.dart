import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/create_user_request.dart';
import '../models/user_model.dart';

class CreateUserViewModel extends ChangeNotifier {
  CreateUserViewModel(this._model);

  final UserModel _model;
  bool _isSubmitting = false;
  bool _requiresLogin = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _createdUserId;

  bool get isSubmitting => _isSubmitting;
  bool get requiresLogin => _requiresLogin;
  String? get errorMessage => _errorMessage;
  String? get createdUserId => _createdUserId;

  Future<bool> submit(CreateUserRequest request, String token) async {
    if (_isSubmitting || _disposed) return false;
    if (request.email.trim().isEmpty ||
        request.password.length < 8 ||
        request.nombre.trim().isEmpty ||
        request.apellidoPat.trim().isEmpty) {
      _errorMessage = 'Completa los campos obligatorios.';
      _notify();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _notify();
    try {
      final created = await _model.create(request, token);
      _createdUserId = created.id;
      _requiresLogin = false;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo crear el usuario. Inténtalo de nuevo.';
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  void reset() {
    _createdUserId = null;
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
