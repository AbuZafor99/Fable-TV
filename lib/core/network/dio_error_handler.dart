import 'package:dio/dio.dart';

import '../models/network_failure.dart';

class DioErrorHandler {
  DioErrorHandler._();

  static NetworkFailure handle(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure(message: 'Connection timed out. Please try again.');
        case DioExceptionType.connectionError:
          return const NetworkFailure(message: 'No internet connection.');
        case DioExceptionType.badCertificate:
          return const NetworkFailure(message: 'Bad server certificate.');
        case DioExceptionType.badResponse:
          return NetworkFailure(
            message: 'Server error (${error.response?.statusCode ?? 'unknown'}).',
            statusCode: error.response?.statusCode,
          );
        case DioExceptionType.cancel:
          return const NetworkFailure(message: 'Request was cancelled.');
        case DioExceptionType.unknown:
          return NetworkFailure(message: error.message ?? 'Something went wrong.');
      }
    }
    return NetworkFailure(message: error.toString());
  }
}
