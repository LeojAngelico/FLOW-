import 'package:dio/dio.dart';

import 'error_codes.dart';
import 'failure.dart';
import 'validation_failure.dart';

class ErrorMapper {
  ErrorMapper._();

  /// Converts technical/network errors into
  /// application-level Failure objects.
  static Failure map(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }

    return const UnknownFailure();
  }

  static Failure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _mapResponse(error.response);

      default:
        return const UnknownFailure();
    }
  }

  static Failure _mapResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;

    switch (statusCode) {
      case 401:
        return _parseApiFailure(
          response,
          fallback: const UnauthorizedFailure(),
        );

      case 400:
      case 422:
        return _parseApiFailure(
          response,
          fallback: const ValidationFailure(ErrorCodes.invalidRequest),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerFailure();

      default:
        return _parseApiFailure(response, fallback: const UnknownFailure());
    }
  }

  /// Converts the backend's common error response
  /// into an application-level Failure.
  static Failure _parseApiFailure(
    Response<dynamic>? response, {
    required Failure fallback,
  }) {
    final data = response?.data;

    // The API did not return the expected JSON structure.
    if (data is! Map<String, dynamic>) {
      return fallback;
    }

    final message = data['msg'];
    final statusCode = data['status_code'];

    // Parse field-level validation errors.
    final errors = _parseFieldErrors(data['errors']);

    // Login / authentication failure.
    if (statusCode == 'UNAUTHORIZED') {
      return UnauthorizedFailure(
        message is String ? message : fallback.message,
      );
    }

    // Registration/form validation failure.
    if (statusCode == 'INVALID_DATA') {
      return ValidationFailure(
        message is String ? message : ErrorCodes.invalidInput,
        fieldErrors: errors,
      );
    }

    return fallback;
  }

  /// Converts the backend's dynamic "errors" object
  /// into a predictable Dart Map.
  static Map<String, List<String>> _parseFieldErrors(dynamic errors) {
    if (errors is! Map) {
      return {};
    }

    final result = <String, List<String>>{};

    for (final entry in errors.entries) {
      final field = entry.key.toString();
      final messages = entry.value;

      if (messages is List) {
        result[field] = messages.map((message) => message.toString()).toList();
      }
    }

    return result;
  }
}
