import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/ticket.dart';
import '../models/ticket_model.dart';

enum TicketListMode { mine, pending }

class TicketListViewModel extends ChangeNotifier {
  TicketListViewModel(this._model, this.mode);

  final TicketModel _model;
  final TicketListMode mode;
  List<Ticket> _tickets = const [];
  bool _isLoading = false;
  bool _requiresLogin = false;
  bool _disposed = false;
  String? _errorMessage;

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  bool get requiresLogin => _requiresLogin;
  String? get errorMessage => _errorMessage;

  Future<void> load(String token) async {
    if (_disposed || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _tickets = const [];
    notifyListeners();
    try {
      _tickets = mode == TicketListMode.mine
          ? await _model.getMyTickets(token)
          : await _model.getPendingTickets(token);
      _requiresLogin = false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _requiresLogin = error.statusCode == 401;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los tickets.';
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
