import 'package:hive_flutter/hive_flutter.dart';

import '../constants/cache_constants.dart';

class HiveInitialization {
  HiveInitialization._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(CacheConstants.channelsBox),
      Hive.openBox<String>(CacheConstants.streamsBox),
      Hive.openBox<String>(CacheConstants.recentBox),
      Hive.openBox<String>(CacheConstants.apiCacheBox),
    ]);
  }
}
