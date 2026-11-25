import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/manager_api_service.dart';
import '../models/manager_demo_model.dart';
import '../models/manager_request.dart';

class ManagerViewModel extends ChangeNotifier {
  ManagerViewModel(
    this._model, {
    this.isPreview = false,
    ManagerApiService? apiService,
  }) : _apiService = apiService ?? ManagerApiService() {
    _requests = _model.requests;
    _allocations = _model.allocations;
    _selectedId = _requests.firstOrNull?.id;
  }

  final ManagerDemoModel _model;
  final ManagerApiService _apiService;
  final bool isPreview;

  late List<ManagerRequest> _requests;
  late Map<ManagerCategory, int> _allocations;
  Map<ManagerCategory, int> _apiSpent = {};

  String? _selectedId;
  String _search = '';
  int _resetVersion = 0;
  ManagerRequestStatus? _statusFilter;
  ManagerCategory? _categoryFilter;
  int _reportMonth = 11;

  bool _isLoading = false;
  final bool _isSaving = false;
  String? _errorMessage;
  String? _authToken;
  String? _departmentId;
  String _departmentName = 'Operaciones';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get departmentName => _departmentName;
  String? get departmentId => _departmentId;

  List<ManagerRequest> get requests => List.unmodifiable(_requests);
  List<ManagerRequest> get monthRequests =>
      _requests.where((r) => r.date.month == 11).toList();
  List<ManagerRequest> get pending => monthRequests
      .where((r) => r.status == ManagerRequestStatus.pending)
      .toList();
  ManagerRequest? get selected =>
      _requests.where((r) => r.id == _selectedId).firstOrNull ??
      _requests.firstOrNull;
  ManagerRequestStatus? get statusFilter => _statusFilter;
  ManagerCategory? get categoryFilter => _categoryFilter;
  int get reportMonth => _reportMonth;
  String get searchQuery => _search;
  int get resetVersion => _resetVersion;

  int get budget => _allocations.values.fold(0, (sum, value) => sum + value);
  int get spent => ManagerCategory.values.fold(
    0,
    (sum, category) => sum + categorySpent(category),
  );
  int get available => budget > spent ? budget - spent : 0;
  int get pendingAmount => pending.fold(0, (sum, r) => sum + r.amountCents);

  int allocation(ManagerCategory category) => _allocations[category] ?? 0;

  int categorySpent(ManagerCategory category) {
    if (!isPreview && _apiSpent.containsKey(category)) {
      return _apiSpent[category]!;
    }
    final previous = _model.previousSpend[category] ?? 0;
    final currentApproved = monthRequests
        .where(
          (r) =>
              r.category == category &&
              r.status == ManagerRequestStatus.approved,
        )
        .fold(0, (sum, r) => sum + r.amountCents);
    return previous + currentApproved;
  }

  List<ManagerRequest> get filteredRequests => _requests.where((r) {
    final matchesStatus = _statusFilter == null || r.status == _statusFilter;
    final matchesCategory =
        _categoryFilter == null || r.category == _categoryFilter;
    final matchesSearch =
        _search.trim().isEmpty ||
        '${r.id} ${r.title} ${r.applicant}'.toLowerCase().contains(
          _search.toLowerCase().trim(),
        );
    return matchesStatus && matchesCategory && matchesSearch;
  }).toList();

  List<ManagerRequest> get reportRequests =>
      _requests.where((r) => r.date.month == _reportMonth).toList();

  int reportCount(ManagerRequestStatus status) =>
      reportRequests.where((r) => r.status == status).length;

  int reportAmount(ManagerRequestStatus status) => reportRequests
      .where((r) => r.status == status)
      .fold(0, (sum, r) => sum + r.amountCents);

  int get reportTotal =>
      reportRequests.fold(0, (sum, r) => sum + r.amountCents);

  void search(String value) {
    _search = value;
    notifyListeners();
  }

  void filterStatus(ManagerRequestStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void filterCategory(ManagerCategory? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void selectRequest(String id) {
    _selectedId = id;
    notifyListeners();
  }

  void selectReportMonth(int month) {
    _reportMonth = month;
    if (!isPreview && _authToken != null) {
      load(
        _authToken!,
        departmentId: _departmentId,
        departmentName: _departmentName,
      );
    } else {
      notifyListeners();
    }
  }

  void setDepartment(String? id, String name) {
    _departmentId = id;
    _departmentName = name;
    if (!isPreview && _authToken != null) {
      load(_authToken!, departmentId: id, departmentName: name);
    } else {
      notifyListeners();
    }
  }

  Future<void> load(
    String token, {
    String? departmentId,
    String? departmentName,
  }) async {
    _authToken = token;
    if (departmentId != null) _departmentId = departmentId;
    if (departmentName != null && departmentName.isNotEmpty) {
      _departmentName = departmentName;
    }

    if (isPreview) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchDepartmentRequests(
          token,
          departmentId: _departmentId,
          month: _reportMonth,
        ),
        _apiService.fetchBudget(
          token,
          departmentId: _departmentId,
          month: _reportMonth,
        ),
      ]);

      final fetchedRequests = results[0] as List<ManagerRequest>;
      final budgetMap = results[1] as Map<String, dynamic>;

      _requests = fetchedRequests;
      if (_selectedId == null || !_requests.any((r) => r.id == _selectedId)) {
        _selectedId = _requests.firstOrNull?.id;
      }

      final categories = (budgetMap['categories'] as List<dynamic>? ?? []);
      final newAllocations = <ManagerCategory, int>{..._model.allocations};
      final newSpent = <ManagerCategory, int>{};

      for (final catItem in categories) {
        if (catItem is Map) {
          final catName = catItem['category']?.toString() ?? '';
          final category = ManagerCategory.fromString(catName);
          final allocated = (catItem['allocatedCents'] as num?)?.toInt() ?? 0;
          final spent = (catItem['spentCents'] as num?)?.toInt() ?? 0;
          newAllocations[category] = allocated;
          newSpent[category] = spent;
        }
      }

      _allocations = newAllocations;
      _apiSpent = newSpent;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Error al sincronizar datos del departamento.';
      _isLoading = false;
      notifyListeners();
    }
  }

  String? decide(
    ManagerRequest request,
    ManagerRequestStatus decision,
    String comment,
  ) {
    final current = _requests.where((r) => r.id == request.id).firstOrNull;
    if (current == null || current.status != ManagerRequestStatus.pending) {
      return 'La solicitud ya fue revisada.';
    }
    if (decision == ManagerRequestStatus.pending) {
      return 'Selecciona aprobar o rechazar.';
    }
    if (decision == ManagerRequestStatus.rejected && comment.trim().isEmpty) {
      return 'Escribe el motivo del rechazo.';
    }
    if (decision == ManagerRequestStatus.approved &&
        request.amountCents >
            allocation(request.category) - categorySpent(request.category)) {
      return 'El monto supera el presupuesto disponible de esta categoría.';
    }

    _requests = _requests
        .map((r) => r.id == request.id ? r.decide(decision, comment.trim()) : r)
        .toList();
    _selectedId = pending.firstOrNull?.id ?? request.id;
    notifyListeners();

    if (!isPreview && _authToken != null) {
      _apiService
          .decideRequest(
            _authToken!,
            requestId: request.id,
            status: decision == ManagerRequestStatus.approved
                ? 'Aprobada'
                : 'Rechazada',
            comment: comment.trim(),
          )
          .then((_) {
            load(
              _authToken!,
              departmentId: _departmentId,
              departmentName: _departmentName,
            );
          })
          .catchError((e) {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
            notifyListeners();
          });
    }

    return null;
  }

  String? updateBudget(Map<ManagerCategory, int> values) {
    for (final category in ManagerCategory.values) {
      final value = values[category];
      if (value == null || value < categorySpent(category) || value <= 0) {
        return 'La asignación de ${category.label.toLowerCase()} debe cubrir lo ejercido y ser mayor a cero.';
      }
    }

    _allocations = Map.of(values);
    notifyListeners();

    if (!isPreview && _authToken != null) {
      final backendAllocations = <String, int>{};
      for (final entry in values.entries) {
        backendAllocations[entry.key.toBackendCategory()] = entry.value;
      }

      _apiService
          .updateBudget(
            _authToken!,
            departmentId: _departmentId,
            month: _reportMonth,
            year: DateTime.now().year,
            allocations: backendAllocations,
          )
          .then((_) {
            load(
              _authToken!,
              departmentId: _departmentId,
              departmentName: _departmentName,
            );
          })
          .catchError((e) {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
            notifyListeners();
          });
    }

    return null;
  }

  void reset() {
    _resetVersion++;
    _requests = _model.requests;
    _allocations = _model.allocations;
    _selectedId = _requests.firstOrNull?.id;
    _search = '';
    _statusFilter = null;
    _categoryFilter = null;
    _reportMonth = 11;
    notifyListeners();
  }
}
