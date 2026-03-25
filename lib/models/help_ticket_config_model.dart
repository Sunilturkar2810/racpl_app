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
  final List<HelpTicketHoliday> holidays;

  const HelpTicketConfigResponse({required this.holidays});

  factory HelpTicketConfigResponse.fromJson(Map<String, dynamic> json) {
    final holidayList = json['holidays'] as List<dynamic>? ?? const [];

    return HelpTicketConfigResponse(
      holidays: holidayList
          .map((item) => HelpTicketHoliday.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
