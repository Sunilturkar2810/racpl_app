import 'dart:convert';

class MomMinute {
  final String minutes;
  final String actionBy;
  final String plannedCompletion;
  final String actualCompletion;
  final int delayedDays;
  final String remarks;

  MomMinute({
    required this.minutes,
    required this.actionBy,
    required this.plannedCompletion,
    required this.actualCompletion,
    required this.delayedDays,
    required this.remarks,
  });

  factory MomMinute.fromJson(Map<String, dynamic> json) {
    return MomMinute(
      minutes: json['minutes']?.toString() ?? '',
      actionBy: json['action_by']?.toString() ?? json['actionBy']?.toString() ?? '',
      plannedCompletion:
          json['planned_completion']?.toString() ?? json['plannedCompletion']?.toString() ?? '',
      actualCompletion:
          json['actual_completion']?.toString() ?? json['actualCompletion']?.toString() ?? '',
      delayedDays: int.tryParse(json['delayed_days']?.toString() ?? json['delayedDays']?.toString() ?? '0') ?? 0,
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minutes': minutes,
      'actionBy': actionBy,
      'plannedCompletion': plannedCompletion,
      'actualCompletion': actualCompletion,
      'delayedDays': delayedDays,
      'remarks': remarks,
    };
  }
}

class Mom {
  final String id;
  final String momId;
  final String project;
  final String date;
  final String time;
  final String location;
  final List<String> raTeamAttendees;
  final List<String> clientTeamAttendees;
  final List<String> vendorTeamAttendees;
  final List<String> otherAttendees;
  final List<MomMinute> minutes;
  final String createdAt;

  Mom({
    required this.id,
    required this.momId,
    required this.project,
    required this.date,
    required this.time,
    required this.location,
    required this.raTeamAttendees,
    required this.clientTeamAttendees,
    required this.vendorTeamAttendees,
    required this.otherAttendees,
    required this.minutes,
    required this.createdAt,
  });

  factory Mom.fromJson(Map<String, dynamic> json) {
    List<dynamic> parseList(dynamic data) {
      if (data == null) return [];
      if (data is List) return data;
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is List) return decoded;
        } catch (_) {}
      }
      return [];
    }

    final minutesData = parseList(json['minutes']);
    final minutesList = minutesData
        .where((m) => m is Map<String, dynamic> || m is Map)
        .map((m) => MomMinute.fromJson(Map<String, dynamic>.from(m as Map)))
        .toList();

    return Mom(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      momId: json['mom_id']?.toString() ?? '',
      project: json['project']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      raTeamAttendees: parseList(
        json['ra_team_attendees'],
      ).map((e) => e.toString()).toList(),
      clientTeamAttendees: parseList(
        json['client_team_attendees'],
      ).map((e) => e.toString()).toList(),
      vendorTeamAttendees: parseList(
        json['vendor_team_attendees'],
      ).map((e) => e.toString()).toList(),
      otherAttendees: parseList(
        json['other_attendees'],
      ).map((e) => e.toString()).toList(),
      minutes: minutesList,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }
}
