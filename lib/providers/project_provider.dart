import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/error_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  late ProjectService _projectService;

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  AppError? _error;

  ProjectProvider({required ProjectService projectService})
    : _projectService = projectService;

  void setProjectService(ProjectService service) {
    _projectService = service;
  }

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  Future<void> fetchProjects() async {
    _setLoading(true);
    _clearError();
    try {
      _projects = await _projectService.getProjects();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProject(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedProject = await _projectService.getProject(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createProject({
    int? id,
    required String name,
    required String address,
    required String location,
    required String clientName,
    required String contactNo,
    required String status,
    required String teamLead,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newProject = await _projectService.createProject(
        id: id,
        name: name,
        address: address,
        location: location,
        clientName: clientName,
        contactNo: contactNo,
        status: status,
        teamLead: teamLead,
      );
      _projects.add(newProject);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(
    int id,
    Map<String, dynamic> data, {
    Map<String, String>? filePaths,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final index = _projects.indexWhere((p) => p.id == id);
      final existingProject = index != -1 ? _projects[index] : null;
      final updated = await _projectService.updateProject(
        id,
        data,
        existingProject: existingProject,
        filePaths: filePaths,
      );
      if (index != -1) {
        _projects[index] = updated;
      }
      if (_selectedProject?.id == id) {
        _selectedProject = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _projectService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      if (_selectedProject?.id == id) {
        _selectedProject = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
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
