import 'package:flutter/foundation.dart';
import '../models/delegation_model.dart';
import '../models/error_model.dart';
import '../models/task_reference_model.dart';
import '../services/delegation_service.dart';

class DelegationProvider extends ChangeNotifier {
  late DelegationService _delegationService;

  List<Delegation> _delegations = [];
  DelegationDetail? _selectedDelegation;
  List<TaskAssignee> _assignees = [];
  List<TaskDepartment> _departments = [];
  List<TaskCategory> _categories = [];
  bool _isLoading = false;
  bool _isMetadataLoading = false;
  AppError? _error;
  AppError? _metadataError;
  String? _activeScope;
  bool _includeDeleted = false;
  bool _deletedOnly = false;

  DelegationProvider({required DelegationService delegationService})
    : _delegationService = delegationService;

  // ============ Setters (for late initialization) ============
  void setDelegationService(DelegationService service) {
    _delegationService = service;
  }

  // Getters
  List<Delegation> get delegations => _delegations;
  DelegationDetail? get selectedDelegation => _selectedDelegation;
  List<TaskAssignee> get assignees => _assignees;
  List<TaskDepartment> get departments => _departments;
  List<TaskCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isMetadataLoading => _isMetadataLoading;
  AppError? get error => _error;
  AppError? get metadataError => _metadataError;
  bool get hasError => _error != null;
  bool get hasMetadataError => _metadataError != null;

  Future<void> fetchDelegations({
    String? scope,
    bool includeDeleted = false,
    bool deletedOnly = false,
  }) async {
    _setLoading(true);
    _clearError();
    _activeScope = scope;
    _includeDeleted = includeDeleted;
    _deletedOnly = deletedOnly;
    try {
      final tasks = await _delegationService.getDelegations(
        scope: scope,
        includeDeleted: includeDeleted,
      );
      _delegations = deletedOnly
          ? tasks.where((task) => task.isDeleted).toList()
          : tasks.where((task) => !task.isDeleted).toList();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshDelegations() async {
    await fetchDelegations(
      scope: _activeScope,
      includeDeleted: _includeDeleted,
      deletedOnly: _deletedOnly,
    );
  }

  Future<void> fetchTaskReferenceData() async {
    _isMetadataLoading = true;
    _metadataError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _delegationService.getAssignees(),
        _delegationService.getDepartments(),
        _delegationService.getCategories(),
      ]);

      _assignees = results[0] as List<TaskAssignee>;
      _departments = results[1] as List<TaskDepartment>;
      _categories = results[2] as List<TaskCategory>;
    } catch (e) {
      _metadataError = e is AppError
          ? e
          : AppError.fromDioException(e);
    } finally {
      _isMetadataLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDelegation(String id) async {
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

  Future<DelegationDetail> getDelegationRaw(String id) {
    return _delegationService.getDelegation(id);
  }

  /// POST /tasks/:id/remarks
  Future<void> addRemark(String taskId, String remark) async {
    await _delegationService.addRemark(taskId, remark);
  }

  Future<void> createDelegation({
    required List<String> doerIds,
    required String taskName,
    String description = '',
    String? dueDate,
    String? category,
    String priority = 'Normal',
    String status = 'Pending',
    List<String> inLoopIds = const [],
    List<String> department = const [],
    List<Map<String, dynamic>> checklistItems = const [],
    bool evidenceRequired = false,
    String? voiceNoteUrl,
    List<String> referenceDocs = const [],
    String referenceDocUrls = '',
    List<Map<String, dynamic>> reminders = const [],
    bool isRepeat = false,
    String? repeatType,
    String? repeatStartDate,
    String? repeatEndDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newDelegations = await _delegationService.createDelegation(
        doerIds: doerIds,
        taskName: taskName,
        description: description,
        dueDate: dueDate,
        category: category,
        priority: priority,
        status: status,
        inLoopIds: inLoopIds,
        department: department,
        checklistItems: checklistItems,
        evidenceRequired: evidenceRequired,
        voiceNoteUrl: voiceNoteUrl,
        referenceDocs: referenceDocs,
        referenceDocUrls: referenceDocUrls,
        reminders: reminders,
        isRepeat: isRepeat,
        repeatType: repeatType,
        repeatStartDate: repeatStartDate,
        repeatEndDate: repeatEndDate,
      );
      _delegations.addAll(newDelegations);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDelegation(String id, {String? status}) async {
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
      if (_selectedDelegation?.task.id == id) {
        _selectedDelegation = DelegationDetail(
           task: updated,
           remarks: _selectedDelegation!.remarks,
           revisions: _selectedDelegation!.revisions,
           reminders: _selectedDelegation!.reminders,
           activity: _selectedDelegation!.activity,
           subtasks: _selectedDelegation!.subtasks,
        );
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDelegation(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _delegationService.deleteDelegation(id);
      _delegations.removeWhere((d) => d.id == id);
      if (_selectedDelegation?.task.id == id) {
        _selectedDelegation = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }



  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
