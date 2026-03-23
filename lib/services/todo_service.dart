import '../models/todo_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class TodoService {
  final DioService _dioService;

  TodoService({required DioService dioService}) : _dioService = dioService;

  Future<List<Todo>> getTodos() async {
    try {
      return await _dioService.get<List<Todo>>(
        '/todos',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Todo.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> getTodo(int id) async {
    try {
      return await _dioService.get<Todo>(
        '/todos/$id',
        fromJson: (json) => Todo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> createTodo({
    required String title,
    required String description,
    required String priority,
    String? dueDate,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'priority': priority,
        if (dueDate != null) 'due_date': dueDate,
      };
      return await _dioService.post<Todo>(
        '/todos',
        data: data,
        fromJson: (json) => Todo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Todo> updateTodo(int id, {String? status, String? priority}) async {
    try {
      final data = {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
      };
      return await _dioService.put<Todo>(
        '/todos/$id',
        data: data,
        fromJson: (json) => Todo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
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
      throw AppError.fromDioException(e);
    }
  }
}
