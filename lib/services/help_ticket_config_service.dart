import '../models/error_model.dart';
import '../models/help_ticket_config_model.dart';
import 'dio_service.dart';

class HelpTicketConfigService {
  final DioService _dioService;

  HelpTicketConfigService({required DioService dioService})
    : _dioService = dioService;

  Future<HelpTicketConfigResponse> getConfig() async {
    try {
      return await _dioService.get<HelpTicketConfigResponse>(
        '/help-ticket-config',
        fromJson: (json) => HelpTicketConfigResponse.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<HelpTicketHoliday> addHoliday({
    required String holidayDate,
    required String description,
  }) async {
    try {
      return await _dioService.post<HelpTicketHoliday>(
        '/help-ticket-config/holidays',
        data: {
          'holiday_date': holidayDate,
          'description': description,
        },
        fromJson: (json) =>
            HelpTicketHoliday.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> removeHoliday(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/help-ticket-config/holidays/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
