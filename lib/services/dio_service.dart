import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../models/error_model.dart';
import '../utils/storage_helper.dart';

class DioService {
  static const String baseUrl = 'https://racpl-erp.vercel.app/api';

  late Dio _dio;
  final StorageHelper _storage;

  DioService({required StorageHelper storage}) : _storage = storage {
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add request interceptor to inject token & log requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request details
          _logRequest(
            method: options.method,
            url: options.uri.toString(),
            headers: options.headers,
            data: options.data,
            queryParameters: options.queryParameters,
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful response
          _logResponse(
            url: response.requestOptions.uri.toString(),
            statusCode: response.statusCode ?? 0,
            data: response.data,
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Log errors
          _logError(
            url: error.requestOptions.uri.toString(),
            statusCode: error.response?.statusCode,
            message: error.message ?? 'Unknown error',
            errorData: error.response?.data,
          );
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Generic GET request
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError(message: e.toString(), type: 'unknown');
    }
  }

  /// Generic POST request
  Future<T> post<T>(
    String endpoint, {
    dynamic data, // Changed to dynamic to support FormData
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError(message: e.toString(), type: 'unknown');
    }
  }

  /// Generic PUT request
  Future<T> put<T>(
    String endpoint, {
    dynamic data, // Changed to dynamic to support FormData
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError(message: e.toString(), type: 'unknown');
    }
  }

  /// Generic DELETE request
  Future<T> delete<T>(
    String endpoint, {
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError(message: e.toString(), type: 'unknown');
    }
  }

  /// Update base URL (useful for production deployment)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // ============= LOGGING METHODS =============

  /// Log API Request
  void _logRequest({
    required String method,
    required String url,
    required Map<String, dynamic> headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    final log = StringBuffer();
    log.writeln('\n╔════════════════════════════════════════════════════════╗');
    log.writeln('║                    📡 API REQUEST                      ║');
    log.writeln('╚════════════════════════════════════════════════════════╝');
    log.writeln('🔗 URL: $url');
    log.writeln('📌 METHOD: $method');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      log.writeln('🔍 PARAMETERS:');
      queryParameters.forEach((key, value) {
        log.writeln('   • $key: $value');
      });
    }

    if (data != null) {
      log.writeln('📦 BODY:');
      if (data is Map) {
        data.forEach((key, value) {
          // Hide sensitive data
          if (key.toLowerCase().contains('password') ||
              key.toLowerCase().contains('token')) {
            log.writeln('   • $key: ••••••••');
          } else {
            log.writeln('   • $key: $value');
          }
        });
      } else {
        log.writeln('   $data');
      }
    }

    if (headers.isNotEmpty) {
      log.writeln('🔐 HEADERS:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          log.writeln('   • $key: Bearer ••••••••');
        } else {
          log.writeln('   • $key: $value');
        }
      });
    }

    log.writeln('');
    developer.log(log.toString(), name: 'API_REQUEST');
    print(log.toString());
  }

  /// Log API Response
  void _logResponse({
    required String url,
    required int statusCode,
    dynamic data,
  }) {
    final log = StringBuffer();
    log.writeln('\n╔════════════════════════════════════════════════════════╗');
    log.writeln('║                   ✅ API RESPONSE                     ║');
    log.writeln('╚════════════════════════════════════════════════════════╝');
    log.writeln('🔗 URL: $url');
    log.writeln('✅ STATUS: $statusCode');
    log.writeln('📦 DATA:');

    if (data is Map) {
      data.forEach((key, value) {
        if (value is String && value.length > 50) {
          log.writeln('   • $key: ${value.substring(0, 50)}...');
        } else if (value is Map) {
          log.writeln('   • $key: {nested object}');
        } else if (value is List) {
          log.writeln('   • $key: [list with ${value.length} items]');
        } else {
          log.writeln('   • $key: $value');
        }
      });
    } else if (data is List) {
      log.writeln('   [List with ${data.length} items]');
    } else {
      log.writeln('   $data');
    }

    log.writeln('');
    developer.log(log.toString(), name: 'API_RESPONSE', level: 800);
    print(log.toString());
  }

  /// Log API Error
  void _logError({
    required String url,
    required int? statusCode,
    required String message,
    dynamic errorData,
  }) {
    final log = StringBuffer();
    log.writeln('\n╔════════════════════════════════════════════════════════╗');
    log.writeln('║                    ❌ API ERROR                       ║');
    log.writeln('╚════════════════════════════════════════════════════════╝');
    log.writeln('🔗 URL: $url');
    log.writeln('❌ STATUS: ${statusCode ?? 'Unknown'}');
    log.writeln('⚠️  MESSAGE: $message');

    if (errorData != null) {
      log.writeln('📦 ERROR DATA:');
      if (errorData is Map) {
        errorData.forEach((key, value) {
          log.writeln('   • $key: $value');
        });
      } else {
        log.writeln('   $errorData');
      }
    }

    log.writeln('');
    developer.log(log.toString(), name: 'API_ERROR', level: 1000);
    print(log.toString());
  }
}
