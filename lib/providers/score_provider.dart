import 'package:flutter/foundation.dart';
import '../models/score_model.dart';
import '../models/error_model.dart';
import '../services/score_service.dart';

class ScoreProvider extends ChangeNotifier {
  late ScoreService _scoreService;

  List<Score> _scores = [];
  Score? _selectedScore;
  bool _isLoading = false;
  AppError? _error;

  ScoreProvider({required ScoreService scoreService})
    : _scoreService = scoreService;

  void setScoreService(ScoreService service) {
    _scoreService = service;
  }

  // Getters
  List<Score> get scores => _scores;
  Score? get selectedScore => _selectedScore;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  double get averageScore {
    if (_scores.isEmpty) return 0.0;
    final total = _scores.fold(0.0, (sum, score) => sum + score.score);
    return total / _scores.length;
  }

  Future<void> fetchScores() async {
    _setLoading(true);
    _clearError();
    try {
      _scores = await _scoreService.getScores();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchScore(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedScore = await _scoreService.getScore(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createScore({
    required int userId,
    required double score,
    required String metric,
    required String month,
    required int year,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newScore = await _scoreService.createScore(
        userId: userId,
        score: score,
        metric: metric,
        month: month,
        year: year,
      );
      _scores.add(newScore);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteScore(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _scoreService.deleteScore(id);
      _scores.removeWhere((s) => s.id == id);
      if (_selectedScore?.id == id) {
        _selectedScore = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectScore(Score score) {
    _selectedScore = score;
    notifyListeners();
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
  }

  void _clearError() {
    _error = null;
  }
}
