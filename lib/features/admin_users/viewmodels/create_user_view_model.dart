import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/create_user_request.dart';
import '../models/user_model.dart';
import '../models/user_role_option.dart';
import '../../departments/models/department.dart';
import '../../departments/models/department_model.dart';

class CreateUserViewModel extends ChangeNotifier {
  CreateUserViewModel(this._model, this._departmentModel);

  final UserModel _model;
  final DepartmentModel _departmentModel;
  List<UserRoleOption> _roles = const [];
  List<Department> _departments = const [];
  UserRoleOption? _selectedRole;
  String? _selectedDepartmentId;
  bool _isLoadingOptions = false;
  String? _optionsError;
  List<UserRoleOption> get roles => _roles;
  List<Department> get departments => _departments;
  UserRoleOption? get selectedRole => _selectedRole;
  String? get selectedDepartmentId => _selectedDepartmentId;
  bool get isLoadingOptions => _isLoadingOptions;
  String? get optionsError => _optionsError;
  bool get requiresDepartment => _selectedRole?.requiresDepartment ?? true;
  String? get selectedDepartmentName => _departments
      .where((d) => d.departmentId == _selectedDepartmentId)
      .firstOrNull
      ?.name;

  Future<void> loadOptions(String token) async {
    if (_disposed || _isLoadingOptions) return;
    _isLoadingOptions = true;
    _optionsError = null;
    _notify();
    try {
      final results = await Future.wait<Object>([
        _model.getRoles(token),
        _departmentModel.fetchAll(token),
      ]);
      if (_disposed) return;
      _roles = results[0] as List<UserRoleOption>;
      _departments = results[1] as List<Department>;
      _selectedRole = _roles
          .where((r) => r.role == (_selectedRole?.role ?? 'colaborador'))
          .firstOrNull;
      if (_roles.isEmpty) {
        _optionsError = 'No hay roles disponibles para crear usuarios.';
      }
      _requiresLogin = false;
    } on ApiException catch (error) {
      _optionsError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _optionsError = 'No se pudieron cargar los roles y departamentos.';
    } finally {
      _isLoadingOptions = false;
      _notify();
    }
  }

  void selectRole(UserRoleOption? role) {
    if (_disposed || _isSubmitting) return;
    _selectedRole = role;
    _notify();
  }

  void selectDepartment(String? id) {
    if (_disposed || _isSubmitting) return;
    _selectedDepartmentId = id;
    _notify();
  }

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
    if (_isLoadingOptions ||
        _optionsError != null ||
        _selectedRole == null ||
        request.role != _selectedRole!.role ||
        !_roles.any((role) => role.role == request.role) ||
        (requiresDepartment &&
            !_departments.any((d) => d.departmentId == request.departmentId))) {
      _errorMessage = 'Selecciona un rol y un departamento válido.';
      _notify();
      return false;
    }
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
    if (_disposed || _isSubmitting) return;
    _selectedRole = _roles
        .where((role) => role.role == 'colaborador')
        .firstOrNull;
    _selectedDepartmentId = null;
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
