import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Maps [DioException] to app exceptions with user-facing messages.
Never throwMappedDio(DioException e) {
  if (e.error is NetworkException) {
    throw e.error as NetworkException;
  }
  throw ServerException(messageFromDio(e));
}

String messageFromDio(DioException e) {
  final status = e.response?.statusCode;
  if (status == 503) {
    return 'The server is temporarily unavailable (503). Please try again in a few minutes.';
  }
  if (status == 502 || status == 504) {
    return 'The server could not be reached ($status). Please try again later.';
  }
  if (status != null && status >= 500) {
    return 'Server error ($status). Please try again later.';
  }
  if (status == 401 || status == 403) {
    return 'Access denied. Check your email and password.';
  }
  if (status == 404) {
    return 'Service not found. Verify the server URL is correct.';
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check your internet and try again.';
    case DioExceptionType.connectionError:
      return 'No connection to the server. Check your internet.';
    case DioExceptionType.badCertificate:
      return 'Secure connection failed. Contact support.';
    default:
      break;
  }
  return e.message ?? 'Request failed';
}
