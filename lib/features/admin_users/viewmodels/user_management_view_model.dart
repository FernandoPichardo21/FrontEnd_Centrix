import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../departments/models/department.dart';
import '../../departments/models/department_model.dart';
import '../models/update_user_request.dart';
import '../models/user_list_item.dart';
import '../models/user_model.dart';
import '../models/user_pagination.dart';
import '../models/user_role_option.dart';
import '../models/users_response.dart';

class UserManagementViewModel extends ChangeNotifier {
  UserManagementViewModel(UserModel userModel, DepartmentModel departmentModel)
    : _userModel = userModel,
      _departmentModel = departmentModel;

  final UserModel _userModel;
  final DepartmentModel _departmentModel;

  List<UserListItem> _users = [];
  UserPagination? _pagination;
  List<Department> _departments = [];
  List<UserRoleOption> _roles = [];

  bool _isLoading = false;
  bool _isActionLoading = false;
  bool _disposed = false;
  bool _requiresLogin = false;
  String? _errorMessage;
  String? _successMessage;

  int _currentPage = 1;
  final int _pageSize = 10;
  String _searchQuery = '';
  String? _selectedRole;
  String? _selectedDepartmentId;

  List<UserListItem> get users => List.unmodifiable(_users);
  UserPagination? get pagination => _pagination;
  List<Department> get departments => List.unmodifiable(_departments);
  List<UserRoleOption> get roles => List.unmodifiable(_roles);

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  bool get requiresLogin => _requiresLogin;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get searchQuery => _searchQuery;
  String? get selectedRole => _selectedRole;
  String? get selectedDepartmentId => _selectedDepartmentId;

  String departmentNameOf(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) {
      return 'Sin departamento';
    }
    for (final dept in _departments) {
      if (dept.departmentId == departmentId) return dept.name;
    }
    return 'Departamento asignado';
  }

  Future<void> loadInitial(String token) async {
    _isLoading = true;
    _errorMessage = null;
    _requiresLogin = false;
    notifyListeners();

    try {
      final results = await Future.wait([
        _departmentModel.fetchAll(token),
        _userModel.fetchUsers(
          token,
          page: _currentPage,
          limit: _pageSize,
          search: _searchQuery,
          role: _selectedRole,
          departmentId: _selectedDepartmentId,
        ),
      ]);

      if (_disposed) return;
      _departments = results[0] as List<Department>;
      final usersResponse = results[1] as UsersResponse;
      _users = usersResponse.items;
      _pagination = usersResponse.pagination;

      try {
        _roles = await _userModel.getRoles(token);
      } catch (_) {
        _roles = const [
          UserRoleOption(role: 'administrador', description: 'Acceso total'),
          UserRoleOption(
            role: 'gerente',
            description: 'Gestión de departamento',
          ),
          UserRoleOption(
            role: 'soporte_tecnico',
            description: 'Atención de incidencias',
          ),
          UserRoleOption(role: 'colaborador', description: 'Usuario estándar'),
        ];
      }
    } on ApiException catch (error) {
      if (_disposed) return;
      _errorMessage = error.message;
      if (error.statusCode == 401) _requiresLogin = true;
    } catch (_) {
      if (_disposed) return;
      _errorMessage = 'No se pudieron cargar los datos de administración.';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadUsers(String token, {int? page}) async {
    if (_disposed) return;
    _isLoading = true;
    _errorMessage = null;
    if (page != null) _currentPage = page;
    notifyListeners();

    try {
      final response = await _userModel.fetchUsers(
        token,
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery,
        role: _selectedRole,
        departmentId: _selectedDepartmentId,
      );

      if (_disposed) return;
      _users = response.items;
      _pagination = response.pagination;
      _currentPage = response.pagination.page;
    } on ApiException catch (error) {
      if (_disposed) return;
      _errorMessage = error.message;
      if (error.statusCode == 401) _requiresLogin = true;
    } catch (_) {
      if (_disposed) return;
      _errorMessage = 'Error al consultar la lista de usuarios.';
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setSearch(String token, String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadUsers(token);
  }

  Future<void> setRoleFilter(String token, String? role) async {
    _selectedRole = (role != null && role.isNotEmpty) ? role : null;
    _currentPage = 1;
    await loadUsers(token);
  }

  Future<void> setDepartmentFilter(String token, String? departmentId) async {
    _selectedDepartmentId = (departmentId != null && departmentId.isNotEmpty)
        ? departmentId
        : null;
    _currentPage = 1;
    await loadUsers(token);
  }

  Future<void> clearFilters(String token) async {
    _searchQuery = '';
    _selectedRole = null;
    _selectedDepartmentId = null;
    _currentPage = 1;
    await loadUsers(token);
  }

  Future<void> nextPage(String token) async {
    if (_pagination?.hasNextPage == true) {
      await loadUsers(token, page: _currentPage + 1);
    }
  }

  Future<void> previousPage(String token) async {
    if (_pagination?.hasPreviousPage == true) {
      await loadUsers(token, page: _currentPage - 1);
    }
  }

  Future<void> goToPage(String token, int page) async {
    if (page >= 1 && (_pagination == null || page <= _pagination!.totalPages)) {
      await loadUsers(token, page: page);
    }
  }

  Future<bool> updateUser(
    String id,
    UpdateUserRequest request,
    String token,
  ) async {
    if (_disposed) return false;
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _userModel.updateUser(id, request, token);
      if (_disposed) return false;
      _successMessage = 'Usuario actualizado exitosamente.';
      await loadUsers(token);
      return true;
    } on ApiException catch (error) {
      if (_disposed) return false;
      _errorMessage = error.message;
      if (error.statusCode == 401) _requiresLogin = true;
      return false;
    } catch (_) {
      if (_disposed) return false;
      _errorMessage = 'No se pudo actualizar el usuario.';
      return false;
    } finally {
      if (!_disposed) {
        _isActionLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteUser(String id, String token) async {
    if (_disposed) return false;
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _userModel.deleteUser(id, token);
      if (_disposed) return false;
      _successMessage = 'Usuario eliminado correctamente.';

      // Si la página queda vacía tras eliminar, ir a la página anterior si es posible
      if (_users.length == 1 && _currentPage > 1) {
        _currentPage--;
      }
      await loadUsers(token);
      return true;
    } on ApiException catch (error) {
      if (_disposed) return false;
      _errorMessage = error.message;
      if (error.statusCode == 401) _requiresLogin = true;
      return false;
    } catch (_) {
      if (_disposed) return false;
      _errorMessage = 'No se pudo eliminar el usuario.';
      return false;
    } finally {
      if (!_disposed) {
        _isActionLoading = false;
        notifyListeners();
      }
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
