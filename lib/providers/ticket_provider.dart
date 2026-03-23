import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/error_model.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  late TicketService _ticketService;

  List<HelpTicket> _tickets = [];
  HelpTicket? _selectedTicket;
  bool _isLoading = false;
  AppError? _error;

  TicketProvider({required TicketService ticketService})
    : _ticketService = ticketService;

  void setTicketService(TicketService service) {
    _ticketService = service;
  }

  // Getters
  List<HelpTicket> get tickets => _tickets;
  HelpTicket? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> fetchTickets() async {
    _setLoading(true);
    _clearError();
    try {
      _tickets = await _ticketService.getTickets();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTicket(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedTicket = await _ticketService.getTicket(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newTicket = await _ticketService.createTicket(
        title: title,
        description: description,
        category: category,
        priority: priority,
      );
      _tickets.add(newTicket);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTicket(int id, {String? status, int? assignedToId}) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _ticketService.updateTicket(
        id,
        status: status,
        assignedToId: assignedToId,
      );
      final index = _tickets.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tickets[index] = updated;
      }
      if (_selectedTicket?.id == id) {
        _selectedTicket = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTicket(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _ticketService.deleteTicket(id);
      _tickets.removeWhere((t) => t.id == id);
      if (_selectedTicket?.id == id) {
        _selectedTicket = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectTicket(HelpTicket ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
  }

  void _clearError() {
    _error = null;
  }
}
