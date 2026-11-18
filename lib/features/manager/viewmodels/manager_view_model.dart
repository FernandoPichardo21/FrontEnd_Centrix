import 'package:flutter/foundation.dart';

import '../models/manager_demo_model.dart';
import '../models/manager_request.dart';

class ManagerViewModel extends ChangeNotifier {
  ManagerViewModel(this._model) {
    _requests = _model.requests;
    _allocations = _model.allocations;
    _selectedId = _requests.first.id;
  }

  final ManagerDemoModel _model;
  late List<ManagerRequest> _requests;
  late Map<ManagerCategory, int> _allocations;
  String? _selectedId;
  String _search = '';
  int _resetVersion = 0;
  ManagerRequestStatus? _statusFilter;
  ManagerCategory? _categoryFilter;
  int _reportMonth = 11;

  List<ManagerRequest> get requests => List.unmodifiable(_requests);
  List<ManagerRequest> get monthRequests =>
      _requests.where((r) => r.date.month == 11).toList();
  List<ManagerRequest> get pending => monthRequests
      .where((r) => r.status == ManagerRequestStatus.pending)
      .toList();
  ManagerRequest? get selected =>
      _requests.where((r) => r.id == _selectedId).firstOrNull;
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
  int get available => budget - spent;
  int get pendingAmount => pending.fold(0, (sum, r) => sum + r.amountCents);
  int allocation(ManagerCategory category) => _allocations[category]!;
  int categorySpent(ManagerCategory category) =>
      _model.previousSpend[category]! +
      monthRequests
          .where(
            (r) =>
                r.category == category &&
                r.status == ManagerRequestStatus.approved,
          )
          .fold(0, (sum, r) => sum + r.amountCents);
  List<ManagerRequest> get filteredRequests => _requests
      .where(
        (r) =>
            (_statusFilter == null || r.status == _statusFilter) &&
            (_categoryFilter == null || r.category == _categoryFilter) &&
            '${r.id} ${r.title} ${r.applicant}'.toLowerCase().contains(
              _search.toLowerCase().trim(),
            ),
      )
      .toList();
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
    notifyListeners();
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
    return null;
  }

  void reset() {
    _resetVersion++;
    _requests = _model.requests;
    _allocations = _model.allocations;
    _selectedId = _requests.first.id;
    _search = '';
    _statusFilter = null;
    _categoryFilter = null;
    _reportMonth = 11;
    notifyListeners();
  }
}
