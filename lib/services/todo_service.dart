import '../models/todo_model.dart';
import '../models/error_model.dart';
import '../utils/storage_helper.dart';
import 'dio_service.dart';

class TodoService {
  final DioService _dioService;
  final StorageHelper _storage;

  TodoService({
    required DioService dioService,
    required StorageHelper storage,
  }) : _dioService = dioService,
       _storage = storage;

  Future<List<Todo>> getTodos() async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        throw AppError(message: 'Please login again to load your to-do items');
      }

      return await _dioService.get<List<Todo>>(
        '/todos/$userId',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Todo.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> getTodo(int id) async {
    try {
      final todos = await getTodos();
      return todos.firstWhere(
        (todo) => todo.id == id,
        orElse: () => throw AppError(message: 'To-do item not found'),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> createTodo({
    required String title,
    required String description,
    required String priority,
    String? dueDate,
    int? assignedTo,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'priority': priority,
        if (assignedTo case final value?) 'assigned_to': value,
        if (dueDate case final value?) 'due_date': value,
      };
      return await _dioService.post<Todo>(
        '/todos',
        data: data,
        fromJson: (json) => Todo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> updateTodo(int id, {String? status, String? priority}) async {
    try {
      if (status == null || status.isEmpty) {
        throw AppError(message: 'Status is required to update a to-do item');
      }

      return await _dioService.patch<Todo>(
        '/todos/$id/status',
        data: {'status': status},
        fromJson: (json) => Todo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/todos/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }
}
