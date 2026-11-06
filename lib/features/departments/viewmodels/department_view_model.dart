import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/department.dart';
import '../models/department_model.dart';

class DepartmentViewModel extends ChangeNotifier {
  DepartmentViewModel(this._model);

  final DepartmentModel _model;
  List<Department> _departments = const [];
  String _searchQuery = '';
  String? _errorMessage;
  bool _isLoading = false;
  bool _requiresLogin = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get requiresLogin => _requiresLogin;
  String? get errorMessage => _errorMessage;
  int get total => _departments.length;
  String get searchQuery => _searchQuery;

  List<Department> get visibleDepartments {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _departments;
    return _departments
        .where((department) {
          return department.name.toLowerCase().contains(query) ||
              (department.description?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
  }

  Future<void> load(String token) async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _errorMessage = null;
    _notify();
    try {
      _departments = await _model.fetchAll(token);
      _requiresLogin = false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los departamentos.';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
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
