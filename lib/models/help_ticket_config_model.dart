class HelpTicketSettings {
  final int id;
  final int stage2TatHours;
  final int stage4TatHours;
  final int stage5TatHours;
  final String officeStartTime;
  final String officeEndTime;
  final List<int> workingDays;
  final String? createdAt;
  final String? updatedAt;

  const HelpTicketSettings({
    required this.id,
    required this.stage2TatHours,
    required this.stage4TatHours,
    required this.stage5TatHours,
    required this.officeStartTime,
    required this.officeEndTime,
    required this.workingDays,
    this.createdAt,
    this.updatedAt,
  });

  factory HelpTicketSettings.fromJson(Map<String, dynamic> json) {
    return HelpTicketSettings(
      id: _parseInt(json['id']),
      stage2TatHours: _parseInt(json['stage2_tat_hours']),
      stage4TatHours: _parseInt(json['stage4_tat_hours']),
      stage5TatHours: _parseInt(json['stage5_tat_hours']),
      officeStartTime: json['office_start_time']?.toString() ?? '',
      officeEndTime: json['office_end_time']?.toString() ?? '',
      workingDays: _parseWorkingDays(json['working_days']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  HelpTicketSettings copyWith({
    int? id,
    int? stage2TatHours,
    int? stage4TatHours,
    int? stage5TatHours,
    String? officeStartTime,
    String? officeEndTime,
    List<int>? workingDays,
    String? createdAt,
    String? updatedAt,
  }) {
    return HelpTicketSettings(
      id: id ?? this.id,
      stage2TatHours: stage2TatHours ?? this.stage2TatHours,
      stage4TatHours: stage4TatHours ?? this.stage4TatHours,
      stage5TatHours: stage5TatHours ?? this.stage5TatHours,
      officeStartTime: officeStartTime ?? this.officeStartTime,
      officeEndTime: officeEndTime ?? this.officeEndTime,
      workingDays: workingDays ?? this.workingDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static HelpTicketSettings empty() {
    return const HelpTicketSettings(
      id: 1,
      stage2TatHours: 24,
      stage4TatHours: 4,
      stage5TatHours: 24,
      officeStartTime: '09:00',
      officeEndTime: '18:00',
      workingDays: [1, 2, 3, 4, 5, 6],
    );
  }
}

class HelpTicketHoliday {
  final int id;
  final String holidayDate;
  final String description;
  final String? createdAt;

  const HelpTicketHoliday({
    required this.id,
    required this.holidayDate,
    required this.description,
    this.createdAt,
  });

  factory HelpTicketHoliday.fromJson(Map<String, dynamic> json) {
    return HelpTicketHoliday(
      id: json['id'] as int? ?? int.tryParse('${json['id']}') ?? 0,
      holidayDate: json['holiday_date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class HelpTicketConfigResponse {
  final HelpTicketSettings settings;
  final List<HelpTicketHoliday> holidays;

  const HelpTicketConfigResponse({
    required this.settings,
    required this.holidays,
  });

  factory HelpTicketConfigResponse.fromJson(Map<String, dynamic> json) {
    final holidayList = (json['holidays'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((item) => !_isDeletedHoliday(item))
        .toList();
    final settingsJson = json['settings'];

    return HelpTicketConfigResponse(
      settings: settingsJson is Map<String, dynamic>
          ? HelpTicketSettings.fromJson(settingsJson)
          : HelpTicketSettings.empty(),
      holidays: holidayList
          .map(HelpTicketHoliday.fromJson)
          .toList(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<int> _parseWorkingDays(dynamic value) {
  if (value is List) {
    return value
        .map((item) => _parseInt(item))
        .where((item) => item > 0)
        .toList();
  }

  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((item) => _parseInt(item.trim()))
        .where((item) => item > 0)
        .toList();
  }

  return const [];
}

bool _isDeletedHoliday(Map<String, dynamic> item) {
  final deleted = item['deleted'];
  if (deleted is bool) {
    return deleted;
  }

  return deleted?.toString().toLowerCase() == 'true';
}
