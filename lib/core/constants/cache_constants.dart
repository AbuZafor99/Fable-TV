class CacheConstants {
  CacheConstants._();

  // ── Hive boxes ───────────────────────────────────────────────────────
  static const String channelsBox = 'channels_box';
  static const String streamsBox = 'streams_box';
  static const String recentBox = 'recent_box';
  static const String apiCacheBox = 'api_cache_box';

  // ── Box keys ─────────────────────────────────────────────────────────
  static const String channelsDataKey = 'channels_data';
  static const String channelsUpdatedAtKey = 'channels_updated_at';
  static const String categoriesDataKey = 'categories_data';
  static const String categoriesUpdatedAtKey = 'categories_updated_at';
  static const String countriesDataKey = 'countries_data';
  static const String countriesUpdatedAtKey = 'countries_updated_at';
  static const String streamIndexKey = 'streams_index';
  static const String streamsUpdatedAtKey = 'streams_updated_at';
  static const String recentChannelsKey = 'recent_channels';
  static const String favoriteChannelsKey = 'favorite_channels';

  // ── Policy ───────────────────────────────────────────────────────────
  static const Duration cacheTtl = Duration(hours: 24);
  static const int maxRecentChannels = 10;
}
