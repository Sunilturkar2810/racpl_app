import '../models/checklist_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class ChecklistService {
  final DioService _dioService;

  ChecklistService({required DioService dioService}) : _dioService = dioService;

  Future<List<Checklist>> getChecklists() async {
    try {
      return await _dioService.get<List<Checklist>>(
        '/checklist',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Checklist.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Checklist> getChecklist(int id) async {
    try {
      return await _dioService.get<Checklist>(
        '/checklist/$id',
        fromJson: (json) => Checklist.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Checklist> createChecklist({
    required String title,
    required String description,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final data = {'title': title, 'description': description, 'items': items};
      return await _dioService.post<Checklist>(
        '/checklist',
        data: data,
        fromJson: (json) => Checklist.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Checklist> updateChecklist(
    int id, {
    String? status,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final data = {
        if (status != null) 'status': status,
        if (items != null) 'items': items,
      };
      return await _dioService.put<Checklist>(
        '/checklist/$id',
        data: data,
        fromJson: (json) => Checklist.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteChecklist(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/checklist/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
