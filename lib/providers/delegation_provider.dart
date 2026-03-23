import 'package:flutter/foundation.dart';
import '../models/delegation_model.dart';
import '../models/error_model.dart';
import '../services/delegation_service.dart';

class DelegationProvider extends ChangeNotifier {
  late DelegationService _delegationService;

  List<Delegation> _delegations = [];
  Delegation? _selectedDelegation;
  bool _isLoading = false;
  AppError? _error;

  DelegationProvider({required DelegationService delegationService})
    : _delegationService = delegationService;

  // ============ Setters (for late initialization) ============
  void setDelegationService(DelegationService service) {
    _delegationService = service;
  }

  // Getters
  List<Delegation> get delegations => _delegations;
  Delegation? get selectedDelegation => _selectedDelegation;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> fetchDelegations() async {
    _setLoading(true);
    _clearError();
    try {
      _delegations = await _delegationService.getDelegations();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDelegation(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedDelegation = await _delegationService.getDelegation(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createDelegation({
    required int delegatedToId,
    required String taskName,
    required String description,
    String? dueDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newDelegation = await _delegationService.createDelegation(
        delegatedToId: delegatedToId,
        taskName: taskName,
        description: description,
        dueDate: dueDate,
      );
      _delegations.add(newDelegation);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDelegation(int id, {String? status}) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _delegationService.updateDelegation(
        id,
        status: status,
      );
      final index = _delegations.indexWhere((d) => d.id == id);
      if (index != -1) {
        _delegations[index] = updated;
      }
      if (_selectedDelegation?.id == id) {
        _selectedDelegation = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDelegation(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _delegationService.deleteDelegation(id);
      _delegations.removeWhere((d) => d.id == id);
      if (_selectedDelegation?.id == id) {
        _selectedDelegation = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectDelegation(Delegation delegation) {
    _selectedDelegation = delegation;
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
