import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../departments/models/department.dart';
import '../../departments/models/department_model.dart';
import '../models/ticket.dart';
import '../models/ticket_model.dart';

class DepartmentTicketsViewModel extends ChangeNotifier {
  DepartmentTicketsViewModel(this._ticketModel, this._departmentModel);

  final TicketModel _ticketModel;
  final DepartmentModel _departmentModel;
  List<Department> _departments = const [];
  List<Ticket> _tickets = const [];
  String? _selectedDepartmentId;
  String? _departmentError;
  String? _ticketError;
  bool _isLoadingDepartments = false;
  bool _isLoadingTickets = false;
  bool _requiresLogin = false;
  bool _disposed = false;
  int _ticketRequestVersion = 0;

  List<Department> get departments => _departments;
  List<Ticket> get tickets => _tickets;
  String? get selectedDepartmentId => _selectedDepartmentId;
  String? get departmentError => _departmentError;
  String? get ticketError => _ticketError;
  bool get isLoadingDepartments => _isLoadingDepartments;
  bool get isLoadingTickets => _isLoadingTickets;
  bool get requiresLogin => _requiresLogin;

  Future<void> loadDepartments(String token) async {
    if (_isLoadingDepartments || _disposed) return;
    _isLoadingDepartments = true;
    _departmentError = null;
    _notify();
    try {
      _departments = await _departmentModel.fetchAll(token);
      if (_departments.isNotEmpty) {
        _selectedDepartmentId = _departments.first.departmentId;
      } else {
        _selectedDepartmentId = null;
        _tickets = const [];
      }
      _requiresLogin = false;
    } on ApiException catch (error) {
      _departmentError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _departmentError = 'No se pudieron cargar los departamentos.';
    } finally {
      _isLoadingDepartments = false;
      _notify();
    }
    if (_departmentError == null && _selectedDepartmentId != null) {
      await loadTickets(token);
    }
  }

  Future<void> selectDepartment(String departmentId, String token) async {
    if (_selectedDepartmentId == departmentId || _disposed) return;
    _selectedDepartmentId = departmentId;
    await loadTickets(token);
  }

  Future<void> loadTickets(String token) async {
    final departmentId = _selectedDepartmentId;
    if (departmentId == null || _disposed) return;
    final requestVersion = ++_ticketRequestVersion;
    _isLoadingTickets = true;
    _ticketError = null;
    _tickets = const [];
    _notify();
    try {
      final result = await _ticketModel.getByDepartment(departmentId, token);
      if (requestVersion != _ticketRequestVersion || _disposed) return;
      _tickets = result;
      _requiresLogin = false;
    } on ApiException catch (error) {
      if (requestVersion != _ticketRequestVersion || _disposed) return;
      _ticketError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      if (requestVersion != _ticketRequestVersion || _disposed) return;
      _ticketError = 'No se pudieron cargar los tickets.';
    } finally {
      if (requestVersion == _ticketRequestVersion && !_disposed) {
        _isLoadingTickets = false;
        _notify();
      }
    }
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
