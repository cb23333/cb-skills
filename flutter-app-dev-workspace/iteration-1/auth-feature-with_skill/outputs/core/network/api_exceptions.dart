import 'package:dio/dio.dart';

/// Custom exception for API errors with user-friendly messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  /// Create from a DioException with friendly error messages.
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please check your internet.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final msg = data is Map
            ? data['message'] ?? data['error'] ?? 'Unknown server error'
            : 'Unknown server error';
        return ApiException(
          _mapStatusCode(status, msg),
          statusCode: status,
        );
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      case DioExceptionType.badCertificate:
        return ApiException('Certificate verification failed.');
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');
      case DioExceptionType.unknown:
        return ApiException('Something went wrong. Please try again.');
    }
  }

  static String _mapStatusCode(int? status, String defaultMessage) {
    switch (status) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'You do not have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'An account with this email already exists.';
      case 422:
        return defaultMessage;
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return defaultMessage;
    }
  }

  @override
  String toString() => message;
}
