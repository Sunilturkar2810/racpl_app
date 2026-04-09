import '../models/delegation_model.dart';
import '../models/error_model.dart';
import '../models/task_reference_model.dart';
import 'dio_service.dart';

class DelegationService {
  final DioService _dioService;

  DelegationService({required DioService dioService})
    : _dioService = dioService;

  Future<List<Delegation>> getDelegations({
    String? scope,
    bool includeDeleted = false,
  }) async {
    try {
      return await _dioService.get<List<Delegation>>(
        '/tasks',
        queryParameters: {
          'scope': scope,
          if (includeDeleted) 'includeDeleted': 'true',
        }..removeWhere((key, value) => value == null),
        fromJson: (json) {
          final list =
              (json as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
          return list
              .map((item) => Delegation.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<DelegationDetail> getDelegation(String id) async {
    try {
      return await _dioService.get<DelegationDetail>(
        '/tasks/$id',
        fromJson: (json) => DelegationDetail.fromJson(
          ((json as Map<String, dynamic>)['data'] ?? json)
              as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<List<Delegation>> createDelegation({
    required List<String> doerIds,
    required String taskName,
    String description = '',
    String? dueDate,
    String? category,
    String priority = 'Normal',
    String status = 'Pending',
    List<String> inLoopIds = const [],
    List<String> department = const [],
    List<Map<String, dynamic>> checklistItems = const [],
    bool evidenceRequired = false,
    String? voiceNoteUrl,
    List<String> referenceDocs = const [],
    String referenceDocUrls = '',
    List<Map<String, dynamic>> reminders = const [],
    bool isRepeat = false,
    String? repeatType,
    String? repeatStartDate,
    String? repeatEndDate,
  }) async {
    try {
      final urlList = referenceDocUrls
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = <String, dynamic>{
        'doerIds': doerIds,
        'taskTitle': taskName,
        'description': description,
        'category': category,
        'priority': priority,
        'status': status,
        'dueDate': dueDate,
        'inLoopIds': inLoopIds,
        'department': department,
        'checklistItems': checklistItems,
        'evidenceRequired': evidenceRequired,
        if (voiceNoteUrl != null && voiceNoteUrl.isNotEmpty) 'voiceNoteUrl': voiceNoteUrl,
        if (urlList.isNotEmpty) 'referenceDocs': urlList,
        if (reminders.isNotEmpty) 'reminders': reminders,
      }..removeWhere((key, value) {
          if (value == null) return true;
          if (value is String && value.isEmpty) return true;
          return false;
        });

      return await _dioService.post<List<Delegation>>(
        '/tasks',
        data: data,
        fromJson: (json) {
          final items =
              ((json as Map<String, dynamic>)['data'] as List<dynamic>? ?? []);
          return items
              .map((item) => Delegation.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<Delegation> updateDelegation(String id, {String? status}) async {
    try {
      final data = {'status': status}..removeWhere((key, value) => value == null);
      return await _dioService.patch<Delegation>(
        '/tasks/$id',
        data: data,
        fromJson: (json) => Delegation.fromJson(
          ((json as Map<String, dynamic>)['data'] ?? json)
              as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteDelegation(String id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/tasks/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  /// POST /tasks/:id/remarks — backend expects { remark: "..." }
  Future<Map<String, dynamic>> addRemark(String taskId, String remark) async {
    try {
      return await _dioService.post<Map<String, dynamic>>(
        '/tasks/$taskId/remarks',
        data: {'remark': remark},
        fromJson: (json) =>
            ((json as Map<String, dynamic>)['data'] ?? json)
                as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  /// PATCH /tasks/:id — update status (and optionally a reason)
  Future<Delegation> updateTaskStatus(
    String id, {
    required String status,
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (reason != null && reason.isNotEmpty) data['reason'] = reason;
      return await _dioService.patch<Delegation>(
        '/tasks/$id',
        data: data,
        fromJson: (json) => Delegation.fromJson(
          ((json as Map<String, dynamic>)['data'] ?? json)
              as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<List<TaskAssignee>> getAssignees() async {
    try {
      return await _dioService.get<List<TaskAssignee>>(
        '/master/employees',
        fromJson: (json) {
          // Handle both: bare List [...] and wrapped { "data": [...] } or { "employees": [...] }
          List<dynamic> list;
          if (json is List) {
            list = json;
          } else if (json is Map<String, dynamic>) {
            final data = json['data'] ?? json['employees'] ?? json['result'] ?? [];
            list = data is List ? data : [];
          } else {
            list = [];
          }
          return list
              .map((item) => TaskAssignee.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<List<TaskDepartment>> getDepartments() async {
    try {
      return await _dioService.get<List<TaskDepartment>>(
        '/departments',
        fromJson: (json) {
          final payload = (json as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
          return payload
              .map(
                (item) => TaskDepartment.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }

  Future<List<TaskCategory>> getCategories() async {
    try {
      return await _dioService.get<List<TaskCategory>>(
        '/categories',
        fromJson: (json) {
          final payload = (json as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
          return payload
              .map(
                (item) => TaskCategory.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        },
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError.fromDioException(e);
    }
  }
}
