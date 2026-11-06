import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../departments/models/department.dart';
import '../../departments/models/department_model.dart';
import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';
import '../models/ticket_priority.dart';

class CreateTicketViewModel extends ChangeNotifier {
  CreateTicketViewModel(this._ticketModel, this._departmentModel);

  final TicketModel _ticketModel;
  final DepartmentModel _departmentModel;
  List<Department> _departments = const [];
  String? _selectedDepartmentId;
  TicketPriority? _selectedPriority;
  String? _errorMessage;
  String? _createdTicketId;
  bool _isLoadingDepartments = false;
  bool _isSubmitting = false;
  bool _requiresLogin = false;
  bool _disposed = false;

  List<Department> get departments => _departments;
  String? get selectedDepartmentId => _selectedDepartmentId;
  TicketPriority? get selectedPriority => _selectedPriority;
  String? get errorMessage => _errorMessage;
  String? get createdTicketId => _createdTicketId;
  bool get isLoadingDepartments => _isLoadingDepartments;
  bool get isSubmitting => _isSubmitting;
  bool get requiresLogin => _requiresLogin;

  Future<void> loadDepartments(String token) async {
    if (_isLoadingDepartments || _disposed) return;
    _isLoadingDepartments = true;
    _errorMessage = null;
    _notify();
    try {
      _departments = await _departmentModel.fetchAll(token);
      _requiresLogin = false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los departamentos.';
    } finally {
      _isLoadingDepartments = false;
      _notify();
    }
  }

  void selectDepartment(String? departmentId) {
    _selectedDepartmentId = departmentId;
    _notify();
  }

  void selectPriority(TicketPriority? priority) {
    _selectedPriority = priority;
    _notify();
  }

  Future<bool> submit({
    required String title,
    required String description,
    required String token,
  }) async {
    if (_isSubmitting || _disposed) return false;
    if (title.trim().isEmpty ||
        description.trim().isEmpty ||
        _selectedDepartmentId == null ||
        _selectedPriority == null) {
      _errorMessage = 'Completa todos los campos para crear el ticket.';
      _notify();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _createdTicketId = null;
    _notify();
    try {
      final ticket = await _ticketModel.create(
        CreateTicketRequest(
          title: title,
          description: description,
          priority: _selectedPriority!,
          departmentId: _selectedDepartmentId!,
        ),
        token,
      );
      _createdTicketId = ticket.id;
      _requiresLogin = false;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo crear el ticket. Inténtalo de nuevo.';
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  void reset() {
    _selectedDepartmentId = null;
    _selectedPriority = null;
    _createdTicketId = null;
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
