import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../models/error_model.dart';
import '../services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  late TodoService _todoService;

  List<Todo> _todos = [];
  Todo? _selectedTodo;
  bool _isLoading = false;
  AppError? _error;

  TodoProvider({required TodoService todoService}) : _todoService = todoService;

  void setTodoService(TodoService service) {
    _todoService = service;
  }

  // Getters
  List<Todo> get todos => _todos;
  Todo? get selectedTodo => _selectedTodo;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  List<Todo> get todoByStatus {
    return _todos.where((t) => _normalizeStatus(t.status) == 'to do').toList();
  }

  List<Todo> get inProgressByStatus {
    return _todos
        .where((t) => _normalizeStatus(t.status) == 'in progress')
        .toList();
  }

  List<Todo> get doneByStatus {
    return _todos
        .where((t) => _normalizeStatus(t.status) == 'completed')
        .toList();
  }

  Future<void> fetchTodos() async {
    _setLoading(true);
    _clearError();
    try {
      _todos = await _todoService.getTodos();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTodo(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedTodo = await _todoService.getTodo(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTodo({
    required String title,
    required String description,
    required String priority,
    String? dueDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newTodo = await _todoService.createTodo(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      _todos.add(newTodo);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTodo(int id, {String? status, String? priority}) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _todoService.updateTodo(
        id,
        status: status,
        priority: priority,
      );
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updated;
      }
      if (_selectedTodo?.id == id) {
        _selectedTodo = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTodo(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _todoService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      if (_selectedTodo?.id == id) {
        _selectedTodo = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectTodo(Todo todo) {
    _selectedTodo = todo;
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

  String _normalizeStatus(String status) => status.trim().toLowerCase();
}
