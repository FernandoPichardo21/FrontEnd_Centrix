import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../departments/models/department.dart';
import '../../departments/models/department_model.dart';
import '../models/create_ticket_request.dart';
import '../models/ticket_model.dart';
import '../models/ticket_priority.dart';
import '../models/ticket_evidence_file.dart';

class CreateTicketViewModel extends ChangeNotifier {
  CreateTicketViewModel(this._ticketModel, this._departmentModel);

  final TicketModel _ticketModel;
  final DepartmentModel _departmentModel;
  List<Department> _departments = const [];
  String? _selectedDepartmentId;
  TicketPriority? _selectedPriority;
  String? _errorMessage;
  String? _createdTicketId;
  TicketEvidenceFile? _selectedEvidence;
  String? _evidenceError;
  bool _evidenceUploaded = false;
  bool _isLoadingDepartments = false;
  bool _isSubmitting = false;
  bool _requiresLogin = false;
  bool _disposed = false;

  List<Department> get departments => _departments;
  String? get selectedDepartmentId => _selectedDepartmentId;
  TicketPriority? get selectedPriority => _selectedPriority;
  String? get errorMessage => _errorMessage;
  String? get createdTicketId => _createdTicketId;
  TicketEvidenceFile? get selectedEvidence => _selectedEvidence;
  String? get evidenceError => _evidenceError;
  bool get evidenceUploaded => _evidenceUploaded;
  bool get hasPendingEvidence =>
      _createdTicketId != null && _selectedEvidence != null;
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
    if (_isSubmitting || _disposed) return;
    _selectedDepartmentId = departmentId;
    _notify();
  }

  void selectPriority(TicketPriority? priority) {
    if (_isSubmitting || _disposed) return;
    _selectedPriority = priority;
    _notify();
  }

  void selectEvidence(TicketEvidenceFile file) {
    if (_disposed || _isSubmitting || _createdTicketId != null) return;
    _evidenceError = null;
    _selectedEvidence = null;
    if (file.bytes.isEmpty || file.bytes.length > 5 * 1024 * 1024) {
      _evidenceError = 'Selecciona un archivo de hasta 5 MB.';
    } else if (![
      'image/jpeg',
      'image/png',
      'video/mp4',
    ].contains(file.mimeType)) {
      _evidenceError = 'Solo se aceptan imágenes JPEG, PNG o videos MP4.';
    } else {
      _selectedEvidence = file;
    }
    _notify();
  }

  void setEvidenceSelectionError(String message) {
    if (_disposed || _isSubmitting || _createdTicketId != null) return;
    _evidenceError = message;
    _notify();
  }

  void removeEvidence() {
    if (_disposed || _isSubmitting) return;
    _selectedEvidence = null;
    _evidenceError = null;
    _notify();
  }

  Future<bool> submit({
    required String title,
    required String description,
    required String token,
  }) async {
    // A saved ticket is never submitted again, even if its attachment failed.
    if (_isSubmitting || _disposed || _createdTicketId != null) return false;
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
    _evidenceError = null;
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
      // Storage needs the ID returned by the creation endpoint.
      await _uploadSelectedEvidence(token);
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

  Future<void> retryEvidenceUpload(String token) async {
    if (_disposed || _isSubmitting || !hasPendingEvidence) return;
    _isSubmitting = true;
    _evidenceError = null;
    _notify();
    try {
      await _uploadSelectedEvidence(token);
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<void> _uploadSelectedEvidence(String token) async {
    final file = _selectedEvidence;
    final ticketId = _createdTicketId;
    if (file == null || ticketId == null) return;
    try {
      await _ticketModel.attachEvidence(ticketId, file, token);
      _evidenceUploaded = true;
      _selectedEvidence = null;
      _evidenceError = null;
      _requiresLogin = false;
    } on ApiException catch (error) {
      _evidenceError = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _evidenceError = 'No se pudo adjuntar la evidencia. Puedes reintentar sin crear otro ticket.';
    }
  }

  void reset() {
    if (_disposed || _isSubmitting) return;
    _selectedDepartmentId = null;
    _selectedPriority = null;
    _createdTicketId = null;
    _selectedEvidence = null;
    _evidenceError = null;
    _evidenceUploaded = false;
    _errorMessage = null;
    _requiresLogin = false;
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
