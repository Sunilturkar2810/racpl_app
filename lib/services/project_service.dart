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
    int? id,
    required String name,
    required String address,
    required String location,
    required String clientName,
    required String contactNo,
    required String status,
    required String teamLead,
  }) async {
    try {
      final data = {
        if (id != null) 'id': id,
        'name': name,
        'address': address,
        'location': location,
        'client_name': clientName,
        'contact_no': contactNo,
        'status': status,
        'team_lead': teamLead,
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

  Future<Project> updateProject(int id, Map<String, dynamic> data) async {
    try {
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
