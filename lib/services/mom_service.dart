import 'package:dio/dio.dart';
import '../models/mom_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class MomService {
  final DioService _dioService;

  MomService({required DioService dioService}) : _dioService = dioService;

  Future<List<Mom>> getMeetings() async {
    return _dioService.get<List<Mom>>(
      '/mom',
      fromJson: (data) {
        try {
          if (data is List) {
            return data
                .where((json) => json is Map)
                .map((json) => Mom.fromJson(Map<String, dynamic>.from(json as Map)))
                .toList();
          } else if (data != null && data['data'] != null) {
            return (data['data'] as List)
                .where((json) => json is Map)
                .map((json) => Mom.fromJson(Map<String, dynamic>.from(json as Map)))
                .toList();
          }
          return [];
        } catch (e, st) {
          print('Error parsing MOMs: $e\\n$st');
          throw AppError(message: 'Error parsing data: $e');
        }
      },
    );
  }

  Future<Mom> getMeeting(String id) async {
    return _dioService.get<Mom>(
      '/mom/$id',
      fromJson: (data) {
        if (data != null && data['mom'] != null) {
          return Mom.fromJson(data['mom'] as Map<String, dynamic>);
        } else if (data != null) {
          return Mom.fromJson(data as Map<String, dynamic>);
        }
        throw AppError(message: 'Meeting not found');
      },
    );
  }

  Future<List<String>> getProjects() async {
    return _dioService.get<List<String>>(
      '/projects',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((p) => p['name']?.toString() ?? 'Unnamed Project')
              .toList();
        }
        return [];
      },
    );
  }

  Future<List<String>> getUsers() async {
    return _dioService.get<List<String>>(
      '/master/employees',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((u) {
                final fName = u['First_Name'] ?? '';
                final lName = u['Last_Name'] ?? '';
                return "$fName $lName".trim();
              })
              .where((name) => name.isNotEmpty)
              .toList();
        }
        return [];
      },
    );
  }

  Future<Mom> createMeeting({
    required String project,
    required String date,
    required String time,
    required String location,
    required List<String> raTeamAttendees,
    required List<String> clientTeamAttendees,
    required List<String> vendorTeamAttendees,
    required List<String> otherAttendees,
    required List<MomMinute> minutes,
  }) async {
    final requestData = {
      'project': project,
      'date': date,
      'time': time,
      'location': location,
      'ra_team_attendees': raTeamAttendees,
      'client_team_attendees': clientTeamAttendees,
      'vendor_team_attendees': vendorTeamAttendees,
      'other_attendees': otherAttendees,
      'minutes': minutes.map((m) => m.toJson()).toList(),
    };

    return _dioService.post<Mom>(
      '/mom',
      data: requestData,
      fromJson: (data) {
        if (data != null && data['mom'] != null) {
          return Mom.fromJson(data['mom'] as Map<String, dynamic>);
        } else if (data != null && data['data'] != null) {
          return Mom.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw AppError(message: 'Failed to create meeting');
      },
    );
  }

  Future<Mom> updateMeeting(
    String id, {
    String? project,
    String? date,
    String? time,
    String? location,
    List<String>? raTeamAttendees,
    List<String>? clientTeamAttendees,
    List<String>? vendorTeamAttendees,
    List<String>? otherAttendees,
    List<MomMinute>? minutes,
  }) async {
    final requestData = {
      if (project != null) 'project': project,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (location != null) 'location': location,
      if (raTeamAttendees != null) 'ra_team_attendees': raTeamAttendees,
      if (clientTeamAttendees != null)
        'client_team_attendees': clientTeamAttendees,
      if (vendorTeamAttendees != null)
        'vendor_team_attendees': vendorTeamAttendees,
      if (otherAttendees != null) 'other_attendees': otherAttendees,
      if (minutes != null) 'minutes': minutes.map((m) => m.toJson()).toList(),
    };

    return _dioService.put<Mom>(
      '/mom/$id',
      data: requestData,
      fromJson: (data) {
        if (data != null && data['updated'] != null) {
          return Mom.fromJson(data['updated'] as Map<String, dynamic>);
        } else if (data != null && data['data'] != null) {
          return Mom.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw AppError(message: 'Failed to update meeting');
      },
    );
  }

  Future<void> deleteMeeting(String id) async {
    return _dioService.delete<void>(
      '/mom/$id',
      fromJson: (data) {}, // void doesn't need to return anything
    );
  }
}
