import 'package:flutter/foundation.dart';
import '../models/checklist_model.dart';
import '../models/error_model.dart';
import '../services/checklist_service.dart';

class ChecklistProvider extends ChangeNotifier {
  late ChecklistService _checklistService;

  List<Checklist> _checklists = [];
  Checklist? _selectedChecklist;
  bool _isLoading = false;
  AppError? _error;

  ChecklistProvider({required ChecklistService checklistService})
    : _checklistService = checklistService;

  // ============ Setters (for late initialization) ============
  void setChecklistService(ChecklistService service) {
    _checklistService = service;
  }

  // Getters
  List<Checklist> get checklists => _checklists;
  Checklist? get selectedChecklist => _selectedChecklist;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> fetchChecklists() async {
    _setLoading(true);
    _clearError();
    try {
      _checklists = await _checklistService.getChecklists();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchChecklist(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedChecklist = await _checklistService.getChecklist(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createChecklist({
    required String title,
    required String description,
    required List<Map<String, dynamic>> items,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newChecklist = await _checklistService.createChecklist(
        title: title,
        description: description,
        items: items,
      );
      _checklists.add(newChecklist);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateChecklist(
    int id, {
    String? status,
    List<Map<String, dynamic>>? items,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _checklistService.updateChecklist(
        id,
        status: status,
        items: items,
      );
      final index = _checklists.indexWhere((c) => c.id == id);
      if (index != -1) {
        _checklists[index] = updated;
      }
      if (_selectedChecklist?.id == id) {
        _selectedChecklist = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteChecklist(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _checklistService.deleteChecklist(id);
      _checklists.removeWhere((c) => c.id == id);
      if (_selectedChecklist?.id == id) {
        _selectedChecklist = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectChecklist(Checklist checklist) {
    _selectedChecklist = checklist;
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
