import '../models/score_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class ScoreService {
  final DioService _dioService;

  ScoreService({required DioService dioService}) : _dioService = dioService;

  Future<List<Score>> getScores() async {
    try {
      return await _dioService.get<List<Score>>(
        '/score',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Score.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Score> getScore(int id) async {
    try {
      return await _dioService.get<Score>(
        '/score/$id',
        fromJson: (json) => Score.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Score> createScore({
    required int userId,
    required double score,
    required String metric,
    required String month,
    required int year,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'score': score,
        'metric': metric,
        'month': month,
        'year': year,
      };
      return await _dioService.post<Score>(
        '/score',
        data: data,
        fromJson: (json) => Score.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteScore(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/score/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
