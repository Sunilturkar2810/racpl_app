import '../models/ticket_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class TicketService {
  final DioService _dioService;

  TicketService({required DioService dioService}) : _dioService = dioService;

  Future<List<HelpTicket>> getTickets() async {
    try {
      return await _dioService.get<List<HelpTicket>>(
        '/help-tickets',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => HelpTicket.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<HelpTicket> getTicket(int id) async {
    try {
      return await _dioService.get<HelpTicket>(
        '/help-tickets/$id',
        fromJson: (json) => HelpTicket.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<HelpTicket> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      };
      return await _dioService.post<HelpTicket>(
        '/help-tickets',
        data: data,
        fromJson: (json) => HelpTicket.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<HelpTicket> updateTicket(
    int id, {
    String? status,
    int? assignedToId,
  }) async {
    try {
      final data = {
        if (status != null) 'status': status,
        if (assignedToId != null) 'assigned_to': assignedToId,
      };
      return await _dioService.put<HelpTicket>(
        '/help-tickets/$id',
        data: data,
        fromJson: (json) => HelpTicket.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteTicket(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/help-tickets/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
