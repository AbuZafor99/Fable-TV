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
  static const String dataVersionKey = 'cache_data_version';

  // ── Policy ───────────────────────────────────────────────────────────
  static const Duration cacheTtl = Duration(hours: 24);
  static const int maxRecentChannels = 10;

  /// Bump whenever the country/channel fetch or merge logic changes in a
  /// way that makes previously cached data (e.g. country lat/lng baked in
  /// by an older centroid map, or channel lists missing newly merged
  /// sources) outdated. This forces a one-time live refetch on next launch
  /// instead of serving stale data for up to [cacheTtl].
  static const int dataVersion = 2;
}
