class Delegation {
  final String id;
  final String delegatedById;
  final String delegatedToId;
  final String taskName;
  final String description;
  final String priority;
  final String category;
  final List<String> departments;
  final List<String> inLoopIds;
  final String status;
  final bool isOverdue;
  final bool isDeleted;
  final int checklistCount;
  final int completedChecklistCount;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool evidenceRequired;
  final List<String> evidenceUrl;
  final List<String> referenceDocs;
  final String? voiceNoteUrl;
  final Map<String, bool> permissions;

  Delegation({
    required this.id,
    required this.delegatedById,
    required this.delegatedToId,
    required this.taskName,
    required this.description,
    required this.priority,
    required this.category,
    required this.departments,
    this.inLoopIds = const [],
    required this.status,
    required this.isOverdue,
    required this.isDeleted,
    required this.checklistCount,
    required this.completedChecklistCount,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.evidenceRequired = false,
    this.evidenceUrl = const [],
    this.referenceDocs = const [],
    this.voiceNoteUrl,
    this.permissions = const {},
  });

  factory Delegation.fromJson(Map<String, dynamic> json) {
    return Delegation(
      id: json['id']?.toString() ?? '',
      delegatedById:
          json['assignerId']?.toString() ??
          json['delegated_by']?.toString() ??
          json['delegatedById']?.toString() ??
          '',
      delegatedToId:
          json['doerId']?.toString() ??
          json['delegated_to']?.toString() ??
          json['delegatedToId']?.toString() ??
          '',
      taskName: json['taskTitle'] ?? json['task_name'] ?? json['taskName'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority']?.toString() ?? 'Normal',
      category: json['category']?.toString() ?? '',
      departments:
          ((json['department'] ?? json['departments']) as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(),
      inLoopIds:
          ((json['inLoopIds'] ?? json['in_loop_ids']) as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(),
      status: json['status']?.toString() ?? 'Pending',
      isOverdue: json['isOverdue'] == true,
      isDeleted:
          json['isDeleted'] == true ||
          ((json['deletedAt'] ?? json['deleted_at'])?.toString().isNotEmpty ??
              false),
      checklistCount: (json['checklistCount'] as num?)?.toInt() ?? 0,
      completedChecklistCount:
          (json['completedChecklistCount'] as num?)?.toInt() ?? 0,
      dueDate: (json['dueDate'] ?? json['due_date']) != null
          ? DateTime.tryParse((json['dueDate'] ?? json['due_date']).toString())
          : null,
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.tryParse(
                  (json['createdAt'] ?? json['created_at']).toString()) ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.tryParse(
              (json['updatedAt'] ?? json['updated_at']).toString(),
            )
          : null,
      deletedAt: (json['deletedAt'] ?? json['deleted_at']) != null
          ? DateTime.tryParse(
              (json['deletedAt'] ?? json['deleted_at']).toString(),
            )
          : null,
      evidenceRequired: json['evidenceRequired'] == true || json['evidence_required'] == true,
      evidenceUrl: ((json['evidenceUrl'] ?? json['evidence_url']) as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      referenceDocs: ((json['referenceDocs'] ?? json['reference_docs']) as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      voiceNoteUrl: json['voiceNoteUrl']?.toString() ?? json['voice_note_url']?.toString(),
      permissions: (() {
        final p = json['permissions'] as Map<String, dynamic>?;
        if (p == null) return <String, bool>{};
        return p.map((k, v) => MapEntry(k, v == true));
      })(),
    );
  }

  Delegation copyWith({
    String? id,
    String? delegatedById,
    String? delegatedToId,
    String? taskName,
    String? description,
    String? priority,
    String? category,
    List<String>? departments,
    List<String>? inLoopIds,
    String? status,
    bool? isOverdue,
    bool? isDeleted,
    int? checklistCount,
    int? completedChecklistCount,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? evidenceRequired,
    List<String>? evidenceUrl,
    List<String>? referenceDocs,
    String? voiceNoteUrl,
    Map<String, bool>? permissions,
  }) {
    return Delegation(
      id: id ?? this.id,
      delegatedById: delegatedById ?? this.delegatedById,
      delegatedToId: delegatedToId ?? this.delegatedToId,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      departments: departments ?? this.departments,
      inLoopIds: inLoopIds ?? this.inLoopIds,
      status: status ?? this.status,
      isOverdue: isOverdue ?? this.isOverdue,
      isDeleted: isDeleted ?? this.isDeleted,
      checklistCount: checklistCount ?? this.checklistCount,
      completedChecklistCount:
          completedChecklistCount ?? this.completedChecklistCount,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      evidenceRequired: evidenceRequired ?? this.evidenceRequired,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
      referenceDocs: referenceDocs ?? this.referenceDocs,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      permissions: permissions ?? this.permissions,
    );
  }
}

class TaskRemark {
  final String id;
  final String remarkText;
  final String createdBy;
  final DateTime createdAt;

  TaskRemark({
    required this.id,
    required this.remarkText,
    required this.createdBy,
    required this.createdAt,
  });

  factory TaskRemark.fromJson(Map<String, dynamic> json) {
    return TaskRemark(
      id: json['id']?.toString() ?? '',
      // Backend sends field as 'remark' (not remark_text)
      remarkText: json['remark'] ?? json['remark_text'] ?? json['remarkText'] ?? '',
      createdBy: json['userId']?.toString() ?? json['user_id']?.toString() ?? json['createdBy']?.toString() ?? '',
      createdAt: DateTime.tryParse(
              ((json['created_at'] ?? json['createdAt']) ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class TaskRevision {
  final String id;
  final String oldDueDate;
  final String newDueDate;
  final String oldStatus;
  final String newStatus;
  final String reason;
  final String changedBy;
  final DateTime createdAt;

  TaskRevision({
    required this.id,
    required this.oldDueDate,
    required this.newDueDate,
    required this.oldStatus,
    required this.newStatus,
    required this.reason,
    required this.changedBy,
    required this.createdAt,
  });

  factory TaskRevision.fromJson(Map<String, dynamic> json) {
    return TaskRevision(
      id: json['id']?.toString() ?? '',
      oldDueDate: json['oldDueDate']?.toString() ?? json['old_due_date']?.toString() ?? '',
      newDueDate: json['newDueDate']?.toString() ?? json['new_due_date']?.toString() ?? '',
      oldStatus: json['oldStatus']?.toString() ?? json['old_status']?.toString() ?? '',
      newStatus: json['newStatus']?.toString() ?? json['new_status']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      changedBy: json['changedBy']?.toString() ?? json['changed_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(
              ((json['created_at'] ?? json['createdAt']) ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class TaskReminder {
  final String id;
  final String type;
  final int timeValue;
  final String timeUnit;
  final String triggerType;
  final DateTime? reminderTime;

  TaskReminder({
    required this.id,
    this.type = '',
    this.timeValue = 0,
    this.timeUnit = '',
    this.triggerType = '',
    this.reminderTime,
  });

  factory TaskReminder.fromJson(Map<String, dynamic> json) {
    return TaskReminder(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      timeValue: (json['timeValue'] as num?)?.toInt() ?? (json['time_value'] as num?)?.toInt() ?? 0,
      timeUnit: json['timeUnit']?.toString() ?? json['time_unit']?.toString() ?? '',
      triggerType: json['triggerType']?.toString() ?? json['trigger_type']?.toString() ?? '',
      reminderTime: () {
        final raw = json['reminderTime'] ?? json['reminder_time'];
        if (raw == null || raw.toString().isEmpty) return null;
        return DateTime.tryParse(raw.toString());
      }(),
    );
  }
}

class TaskActivity {
  final String id;
  // Backend sends: eventType, message, actorId
  final String action;      // maps to eventType
  final String description; // maps to message
  final String createdBy;   // maps to actorId
  final DateTime createdAt;

  TaskActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    return TaskActivity(
      id: json['id']?.toString() ?? '',
      action: json['eventType']?.toString() ?? json['event_type']?.toString() ?? json['action']?.toString() ?? '',
      description: json['message']?.toString() ?? json['description']?.toString() ?? '',
      createdBy: json['actorId']?.toString() ?? json['actor_id']?.toString() ?? json['createdBy']?.toString() ?? '',
      createdAt: DateTime.tryParse(
              ((json['created_at'] ?? json['createdAt']) ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class DelegationDetail {
  final Delegation task;
  final List<TaskRemark> remarks;
  final List<TaskRevision> revisions;
  final List<TaskReminder> reminders;
  final List<TaskActivity> activity;
  final List<Delegation> subtasks;

  DelegationDetail({
    required this.task,
    required this.remarks,
    required this.revisions,
    required this.reminders,
    required this.activity,
    required this.subtasks,
  });

  factory DelegationDetail.fromJson(Map<String, dynamic> json) {
    return DelegationDetail(
      task: Delegation.fromJson(json),
      remarks: (json['remarks'] as List<dynamic>? ?? [])
          .map((e) => TaskRemark.fromJson(e as Map<String, dynamic>))
          .toList(),
      revisions: (json['revisions'] as List<dynamic>? ?? [])
          .map((e) => TaskRevision.fromJson(e as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((e) => TaskReminder.fromJson(e as Map<String, dynamic>))
          .toList(),
      activity: (json['activity'] as List<dynamic>? ?? [])
          .map((e) => TaskActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((e) => Delegation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
