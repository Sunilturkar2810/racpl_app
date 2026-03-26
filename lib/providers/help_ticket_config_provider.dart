import 'package:flutter/foundation.dart';

import '../models/error_model.dart';
import '../models/help_ticket_config_model.dart';
import '../services/help_ticket_config_service.dart';

class HelpTicketConfigProvider extends ChangeNotifier {
  final HelpTicketConfigService _service;

  HelpTicketConfigProvider({required HelpTicketConfigService service})
    : _service = service;

  List<HelpTicketHoliday> _holidays = [];
  HelpTicketSettings _settings = HelpTicketSettings.empty();
  bool _isLoading = false;
  bool _isSaving = false;
  int? _deletingHolidayId;
  bool _hasLoaded = false;
  AppError? _error;

  List<HelpTicketHoliday> get holidays => _holidays;
  HelpTicketSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  int? get deletingHolidayId => _deletingHolidayId;
  bool get hasLoaded => _hasLoaded;
  AppError? get error => _error;

  Future<void> fetchConfig({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !forceRefresh) return;

    _isLoading = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      final response = await _service.getConfig();
      _settings = response.settings;
      _holidays = response.holidays;
      _hasLoaded = true;
    } catch (e) {
      _setError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addHoliday({
    required String holidayDate,
    required String description,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      final holiday = await _service.addHoliday(
        holidayDate: holidayDate,
        description: description,
      );
      _holidays = [..._holidays, holiday]
        ..sort((a, b) => a.holidayDate.compareTo(b.holidayDate));
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings({
    required int stage2TatHours,
    required int stage4TatHours,
    required int stage5TatHours,
    required String officeStartTime,
    required String officeEndTime,
    required List<int> workingDays,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      _settings = await _service.updateConfig(
        stage2TatHours: stage2TatHours,
        stage4TatHours: stage4TatHours,
        stage5TatHours: stage5TatHours,
        officeStartTime: officeStartTime,
        officeEndTime: officeEndTime,
        workingDays: workingDays,
      );
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removeHoliday(int id) async {
    if (_deletingHolidayId != null) return false;

    _deletingHolidayId = id;
    _clearError(notify: false);
    notifyListeners();

    try {
      await _service.removeHoliday(id);
      _holidays = _holidays.where((holiday) => holiday.id != id).toList();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _deletingHolidayId = null;
      notifyListeners();
    }
  }

  void clearError() => _clearError();

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
  }

  void _clearError({bool notify = true}) {
    _error = null;
    if (notify) {
      notifyListeners();
    }
  }
}
