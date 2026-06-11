import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../constants/cache_constants.dart';
import '../../models/hive_cache_model.dart';
import '../../utils/debug_print.dart';

/// Caches successful GET responses in Hive and serves them back when the
/// same request fails (offline / server down), as long as the cached entry
/// is younger than [CacheConstants.cacheTtl].
class CustomCacheInterceptor extends Interceptor {
  Box<String> get _box => Hive.box<String>(CacheConstants.apiCacheBox);

  String _cacheKey(RequestOptions options) => options.uri.toString();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final status = response.statusCode ?? 0;
    if (options.method == 'GET' && status >= 200 && status < 300) {
      try {
        final isPlain = response.data is String;
        final model = HiveCacheModel(
          data: isPlain ? response.data as String : jsonEncode(response.data),
          isPlainText: isPlain,
          createdAt: DateTime.now(),
        );
        _box.put(_cacheKey(options), model.encode());
      } catch (e) {
        dPrint('Cache write skipped: $e');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    if (options.method == 'GET') {
      final cached = HiveCacheModel.decode(_box.get(_cacheKey(options)));
      if (cached != null && !cached.isStale(CacheConstants.cacheTtl)) {
        dPrint('Serving from cache: ${options.uri}');
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: cached.isPlainText ? cached.data : jsonDecode(cached.data),
        ));
        return;
      }
    }
    handler.next(err);
  }
}
