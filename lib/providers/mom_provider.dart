import 'package:flutter/foundation.dart';
import '../models/mom_model.dart';
import '../models/error_model.dart';
import '../services/mom_service.dart';

class MomProvider extends ChangeNotifier {
  late MomService _momService;

  List<Mom> _meetings = [];
  List<String> _projects = [];
  List<String> _users = [];
  Mom? _selectedMeeting;
  bool _isLoading = false;
  AppError? _error;

  MomProvider({required MomService momService}) : _momService = momService;

  void setMomService(MomService service) {
    _momService = service;
  }

  List<Mom> get meetings => _meetings;
  List<String> get projects => _projects;
  List<String> get users => _users;
  Mom? get selectedMeeting => _selectedMeeting;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> fetchMeetings() async {
    _setLoading(true);
    _clearError();
    try {
      _meetings = await _momService.getMeetings();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching MOMs: $e');
      }
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFormData() async {
    _setLoading(true);
    _clearError();
    try {
      _projects = await _momService.getProjects();
      _users = await _momService.getUsers();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMeeting(String id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedMeeting = await _momService.getMeeting(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createMeeting({
    required String project,
    required String date,
    required String time,
    required String location,
    required List<String> raTeamAttendees,
    required List<String> clientTeamAttendees,
    required List<String> vendorTeamAttendees,
    required List<String> otherAttendees,
    required List<MomMinute> minutes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newMeeting = await _momService.createMeeting(
        project: project,
        date: date,
        time: time,
        location: location,
        raTeamAttendees: raTeamAttendees,
        clientTeamAttendees: clientTeamAttendees,
        vendorTeamAttendees: vendorTeamAttendees,
        otherAttendees: otherAttendees,
        minutes: minutes,
      );
      _meetings.add(newMeeting);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMeeting(
    String id, {
    String? project,
    String? date,
    String? time,
    String? location,
    List<String>? raTeamAttendees,
    List<String>? clientTeamAttendees,
    List<String>? vendorTeamAttendees,
    List<String>? otherAttendees,
    List<MomMinute>? minutes,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _momService.updateMeeting(
        id,
        project: project,
        date: date,
        time: time,
        location: location,
        raTeamAttendees: raTeamAttendees,
        clientTeamAttendees: clientTeamAttendees,
        vendorTeamAttendees: vendorTeamAttendees,
        otherAttendees: otherAttendees,
        minutes: minutes,
      );
      final index = _meetings.indexWhere((m) => m.id == id);
      if (index != -1) {
        _meetings[index] = updated;
      }
      if (_selectedMeeting?.id == id) {
        _selectedMeeting = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMeeting(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _momService.deleteMeeting(id);
      _meetings.removeWhere((m) => m.id == id);
      if (_selectedMeeting?.id == id) {
        _selectedMeeting = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectMeeting(Mom meeting) {
    _selectedMeeting = meeting;
    notifyListeners();
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError(message: error.toString());
  }

  void _clearError() {
    _error = null;
  }
}
