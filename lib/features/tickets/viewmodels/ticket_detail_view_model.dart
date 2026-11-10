import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/ticket.dart';
import '../models/ticket_assignee.dart';
import '../models/ticket_model.dart';
import '../models/ticket_status.dart';
import '../models/ticket_evidence.dart';

class TicketDetailViewModel extends ChangeNotifier {
  TicketDetailViewModel(this._model, this.ticketId, this.canManage);

  final TicketModel _model;
  final String ticketId;
  final bool canManage;
  Ticket? _ticket;
  List<TicketAssignee> _assignees = const [];
  List<TicketEvidence> _evidences = const [];
  String? _evidenceError;
  bool _isLoadingEvidences = false;
  String? _selectedAssigneeId;
  TicketStatus? _selectedStatus;
  String? _errorMessage;
  String? _assigneesError;
  String? _actionMessage;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _requiresLogin = false;
  bool _disposed = false;

  Ticket? get ticket => _ticket;
  List<TicketAssignee> get assignees => _assignees;
  List<TicketEvidence> get evidences => _evidences;
  String? get evidenceError => _evidenceError;
  bool get isLoadingEvidences => _isLoadingEvidences;
  String? get selectedAssigneeId => _selectedAssigneeId;
  TicketStatus? get selectedStatus => _selectedStatus;
  String? get errorMessage => _errorMessage;
  String? get assigneesError => _assigneesError;
  String? get actionMessage => _actionMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get requiresLogin => _requiresLogin;

  Future<void> load(String token) async {
    if (_disposed || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _ticket = null;
    _notify();
    try {
      final ticket = await _model.getById(ticketId, token);
      if (_disposed) return;
      _ticket = ticket;
      _selectedStatus = TicketStatus.values
          .where(
            (status) =>
                status.apiValue.toLowerCase() == ticket.status.toLowerCase(),
          )
          .firstOrNull;
      _selectedAssigneeId = ticket.assignedToId;
      _requiresLogin = false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _errorMessage = 'No se pudo cargar el ticket.';
    } finally {
      _isLoading = false;
      _notify();
    }
    if (canManage && _ticket != null && !_disposed) await loadAssignees(token);
    if (_ticket != null && !_disposed) await loadEvidences(token);
  }

  Future<void> loadEvidences(String token) async {
    if (_disposed || _ticket == null || _isLoadingEvidences) return;
    _isLoadingEvidences = true;
    _evidenceError = null;
    _notify();
    try {
      _evidences = await _model.getEvidences(ticketId, token);
      _requiresLogin = false;
    } on ApiException catch (error) {
      _evidenceError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _evidenceError = 'No se pudieron cargar las evidencias.';
    } finally {
      _isLoadingEvidences = false;
      _notify();
    }
  }

  Future<void> loadAssignees(String token) async {
    if (_disposed || !canManage) return;
    _assigneesError = null;
    _notify();
    try {
      _assignees = await _model.getAssignees(token);
      if (!_assignees.any((user) => user.id == _selectedAssigneeId)) {
        _selectedAssigneeId = null;
      }
      _requiresLogin = false;
    } on ApiException catch (error) {
      _assigneesError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _assigneesError = 'No se pudieron cargar los usuarios.';
    } finally {
      _notify();
    }
  }

  void selectAssignee(String? id) {
    _selectedAssigneeId = id;
    _notify();
  }

  void selectStatus(TicketStatus? status) {
    _selectedStatus = status;
    _notify();
  }

  Future<void> assign(String token) async {
    final id = _selectedAssigneeId;
    if (_disposed || !canManage || _isSaving || id == null) return;
    await _save(
      () => _model.assign(ticketId, id, token),
      token,
      'Ticket asignado.',
    );
  }

  Future<void> updateStatus(String token) async {
    final status = _selectedStatus;
    if (_disposed || !canManage || _isSaving || status == null) return;
    await _save(
      () => _model.updateStatus(ticketId, status, token),
      token,
      'Estado actualizado.',
    );
  }

  Future<void> _save(
    Future<void> Function() action,
    String token,
    String message,
  ) async {
    _isSaving = true;
    _actionMessage = null;
    _notify();
    try {
      await action();
      _actionMessage = message;
      _requiresLogin = false;
      try {
        _ticket = await _model.getById(ticketId, token);
      } on ApiException {
        _actionMessage =
            '$message Actualiza el detalle para ver los datos nuevos.';
      }
    } on ApiException catch (error) {
      _actionMessage = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _actionMessage = 'No se pudo guardar el cambio.';
    } finally {
      _isSaving = false;
      _notify();
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
