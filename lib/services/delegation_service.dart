import '../models/delegation_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class DelegationService {
  final DioService _dioService;

  DelegationService({required DioService dioService})
    : _dioService = dioService;

  Future<List<Delegation>> getDelegations() async {
    try {
      return await _dioService.get<List<Delegation>>(
        '/delegations',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Delegation.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Delegation> getDelegation(int id) async {
    try {
      return await _dioService.get<Delegation>(
        '/delegations/$id',
        fromJson: (json) => Delegation.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Delegation> createDelegation({
    required int delegatedToId,
    required String taskName,
    required String description,
    String? dueDate,
  }) async {
    try {
      final data = {
        'delegated_to': delegatedToId,
        'task_name': taskName,
        'description': description,
        if (dueDate != null) 'due_date': dueDate,
      };
      return await _dioService.post<Delegation>(
        '/delegations',
        data: data,
        fromJson: (json) => Delegation.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Delegation> updateDelegation(int id, {String? status}) async {
    try {
      final data = {if (status != null) 'status': status};
      return await _dioService.put<Delegation>(
        '/delegations/$id',
        data: data,
        fromJson: (json) => Delegation.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteDelegation(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/delegations/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
