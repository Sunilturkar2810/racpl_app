import 'package:dio/dio.dart';

class AppError {
  final String message;
  final int? code;
  final String type; // 'validation', 'network', 'server', 'unknown'

  AppError({required this.message, this.code, this.type = 'unknown'});

  factory AppError.fromDioException(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] ?? 'Server error'
            : 'Server error';
        return AppError(
          message: message,
          code: error.response?.statusCode,
          type: 'server',
        );
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return AppError(
          message: 'Connection timeout. Please check your internet connection.',
          type: 'network',
        );
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return AppError(
          message: 'Request timeout. Please try again.',
          type: 'network',
        );
      } else if (error.type == DioExceptionType.unknown) {
        return AppError(
          message: 'Network error. Please check your internet connection.',
          type: 'network',
        );
      }
    }
    return AppError(message: 'An unexpected error occurred', type: 'unknown');
  }

  @override
  String toString() => message;
}
