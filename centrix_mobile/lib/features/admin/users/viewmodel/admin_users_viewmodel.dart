import 'package:flutter/foundation.dart';
import '../data/http_admin_user_repository.dart';
import '../domain/admin_user.dart';
import '../domain/admin_user_repository.dart';
import '../domain/create_user_request.dart';

/// Estado y operaciones de la pantalla de administración de usuarios.
class AdminUsersViewModel extends ChangeNotifier {
  AdminUsersViewModel(this._repository);

  final AdminUserRepository _repository;

  List<AdminUser> _users = const [];
  List<AdminUser> get users => List.unmodifiable(_users);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadError;
  String? get loadError => _loadError;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Carga los usuarios y expone carga, resultado o error a la vista.
  Future<void> loadUsers() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      _users = await _repository.fetchAll();
    } on AdminUserRequestException catch (error) {
      _loadError = error.message;
    } catch (_) {
      _loadError = 'No fue posible consultar los usuarios';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registra un usuario y actualiza el directorio cuando termina con éxito.
  Future<bool> createUser(CreateUserRequest request) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.create(request);
      _successMessage = 'Usuario creado correctamente';
      await loadUsers();
      return true;
    } on AdminUserRequestException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible crear el usuario';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
