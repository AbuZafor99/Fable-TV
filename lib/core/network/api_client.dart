import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../models/network_success.dart';
import 'dio_error_handler.dart';
import 'interceptor/custom_cache_interceptor.dart';
import 'network_result.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 40),
      responseType: ResponseType.json,
    ));
    _dio.interceptors.add(CustomCacheInterceptor());
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio _dio;

  Future<NetworkResult<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response =
          await _dio.get(url, queryParameters: queryParameters, options: options);
      return Right(NetworkSuccess(data: response.data, statusCode: response.statusCode));
    } catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }

  /// Fetches the raw response body as a String so large payloads can be
  /// json-decoded off the main isolate by the caller.
  Future<NetworkResult<String>> getPlain(String url) async {
    try {
      final response =
          await _dio.get<String>(url, options: Options(responseType: ResponseType.plain));
      return Right(NetworkSuccess(data: response.data ?? '', statusCode: response.statusCode));
    } catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }

  Future<NetworkResult<dynamic>> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(url,
          data: data, queryParameters: queryParameters, options: options);
      return Right(NetworkSuccess(data: response.data, statusCode: response.statusCode));
    } catch (e) {
      return Left(DioErrorHandler.handle(e));
    }
  }
}
