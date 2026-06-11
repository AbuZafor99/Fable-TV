import 'package:get/get.dart';

import '../../../../core/base/base_controller.dart';
import '../../../../core/constants/cache_constants.dart';
import '../../../../core/services/channel_cache_service.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../player/domain/repository/stream_repository.dart';
import '../../data/models/category_model.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/country_model.dart';
import '../../domain/repository/channel_repository.dart';

class HomeController extends BaseController {
  final ChannelRepository _channelRepository = Get.find();
  final StreamRepository _streamRepository = Get.find();
  final ChannelCacheService _cacheService = Get.find();

  final RxList<ChannelModel> recentChannels = <ChannelModel>[].obs;
  final RxList<ChannelModel> favoriteChannels = <ChannelModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CountryModel> countries = <CountryModel>[].obs;
  final RxList<ChannelModel> allChannels = <ChannelModel>[].obs;
  final RxMap<String, List<ChannelModel>> channelsByCategory =
      <String, List<ChannelModel>>{}.obs;
  final RxMap<String, int> channelCountByCountry = <String, int>{}.obs;
  final RxBool isLoadingChannels = true.obs;
  final RxBool isRefreshing = false.obs;

  Map<String, CountryModel> get countryByCode =>
      {for (final c in countries) c.code: c};

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void onInit() {
    super.onInit();
    _loadRecentChannels();
    _loadFavorites();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadCountries();
    await _loadCategories();
    await _loadChannels();
    // Stream index download is heavy (30k+ items); refresh it in the
    // background without blocking the UI.
    // ignore: unawaited_futures
    _ensureStreamIndex();
  }

  Future<void> _loadRecentChannels() async {
    recentChannels.assignAll(await _cacheService.getRecentChannels());
  }

  Future<void> _loadFavorites() async {
    favoriteChannels.assignAll(await _cacheService.getFavoriteChannels());
  }

  Future<void> _loadCountries() async {
    final cached = _cacheService.getCachedCountries(allowStale: true);
    if (cached != null) countries.assignAll(cached);
    if (cached == null || _cacheService.isCacheStale(_countriesStaleKey)) {
      final result = await _channelRepository.fetchCountries();
      result.fold(
        (failure) => dPrint('fetchCountries failed: ${failure.message}'),
        (success) {
          countries.assignAll(success.data);
          _cacheService.cacheCountries(success.data);
        },
      );
    }
  }

  Future<void> _loadCategories() async {
    final cached = _cacheService.getCachedCategories(allowStale: true);
    if (cached != null) categories.assignAll(cached);
    if (cached == null || _cacheService.isCacheStale(_categoriesStaleKey)) {
      final result = await _channelRepository.fetchCategories();
      result.fold(
        (failure) => dPrint('fetchCategories failed: ${failure.message}'),
        (success) {
          categories.assignAll(success.data);
          _cacheService.cacheCategories(success.data);
        },
      );
    }
  }

  Future<void> _loadChannels() async {
    final cached = await _cacheService.getCachedChannels(allowStale: true);
    if (cached != null && cached.isNotEmpty) {
      _publishChannels(cached);
      isLoadingChannels.value = false;
      if (_cacheService.isCacheStale(_channelsStaleKey)) {
        // Stale: refresh silently behind the already-rendered UI.
        // ignore: unawaited_futures
        _fetchAndCacheChannels();
      }
      return;
    }
    // First launch: no cache, show shimmer until the live fetch lands.
    await _fetchAndCacheChannels();
    isLoadingChannels.value = false;
  }

  Future<void> _fetchAndCacheChannels() async {
    final result = await _channelRepository.fetchAllChannels();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        dPrint('fetchAllChannels failed: ${failure.message}');
      },
      (success) {
        final lookup = countryByCode;
        final joined =
            success.data.map((c) => c.withCountry(lookup[c.country])).toList();
        _publishChannels(joined);
        _cacheService.cacheChannels(joined);
      },
    );
  }

  void _publishChannels(List<ChannelModel> channels) {
    allChannels.assignAll(channels);
    final byCategory = <String, List<ChannelModel>>{};
    final byCountry = <String, int>{};
    for (final channel in channels) {
      for (final cat in channel.categories) {
        byCategory.putIfAbsent(cat, () => []).add(channel);
      }
      if (channel.country.isNotEmpty) {
        byCountry[channel.country] = (byCountry[channel.country] ?? 0) + 1;
      }
    }
    channelsByCategory.assignAll(byCategory);
    channelCountByCountry.assignAll(byCountry);
  }

  Future<void> _ensureStreamIndex() async {
    if (_cacheService.hasStreamIndex &&
        !_cacheService.isCacheStale(_streamsStaleKey)) {
      return;
    }
    final result = await _streamRepository.fetchAllStreams();
    result.fold(
      (failure) => dPrint('fetchAllStreams failed: ${failure.message}'),
      (success) => _cacheService.buildStreamIndex(success.data),
    );
  }

  Future<void> refreshAll() async {
    isRefreshing.value = true;
    try {
      await _fetchAndCacheChannels();
      await _ensureStreamIndex();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> addToRecent(ChannelModel channel) async {
    await _cacheService.addToRecent(channel);
    await _loadRecentChannels();
  }

  bool isFavorite(String channelId) =>
      favoriteChannels.any((c) => c.id == channelId);

  Future<bool> toggleFavorite(ChannelModel channel) async {
    final nowFavorite = await _cacheService.toggleFavorite(channel);
    await _loadFavorites();
    return nowFavorite;
  }

  static const _channelsStaleKey = CacheConstants.channelsUpdatedAtKey;
  static const _categoriesStaleKey = CacheConstants.categoriesUpdatedAtKey;
  static const _countriesStaleKey = CacheConstants.countriesUpdatedAtKey;
  static const _streamsStaleKey = CacheConstants.streamsUpdatedAtKey;
}
