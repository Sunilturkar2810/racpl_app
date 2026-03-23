import '../models/project_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class ProjectService {
  final DioService _dioService;

  ProjectService({required DioService dioService}) : _dioService = dioService;

  Future<List<Project>> getProjects() async {
    try {
      return await _dioService.get<List<Project>>(
        '/projects',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Project.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> getProject(int id) async {
    try {
      return await _dioService.get<Project>(
        '/projects/$id',
        fromJson: (json) => Project.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> createProject({
    required String name,
    required String description,
    String? startDate,
    String? endDate,
    double? budget,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (budget != null) 'budget': budget,
      };
      return await _dioService.post<Project>(
        '/projects',
        data: data,
        fromJson: (json) => Project.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> updateProject(int id, {String? status}) async {
    try {
      final data = {if (status != null) 'status': status};
      return await _dioService.put<Project>(
        '/projects/$id',
        data: data,
        fromJson: (json) => Project.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/projects/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
