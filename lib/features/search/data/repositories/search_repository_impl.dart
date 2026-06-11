import '../../../../core/services/channel_cache_service.dart';
import '../../../home/data/models/channel_model.dart';
import '../../domain/repository/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final ChannelCacheService channelCache;

  SearchRepositoryImpl({required this.channelCache});

  @override
  Future<List<ChannelModel>> searchChannels({
    required String query,
    List<String> categories = const [],
    String country = '',
  }) async {
    final all = await channelCache.getCachedChannels(allowStale: true) ?? [];
    final q = query.toLowerCase().trim();
    return all.where((c) {
      if (q.isNotEmpty &&
          !c.name.toLowerCase().contains(q) &&
          !c.altNames.any((n) => n.toLowerCase().contains(q)) &&
          !c.countryName.toLowerCase().contains(q)) {
        return false;
      }
      if (categories.isNotEmpty &&
          !c.categories.any((cat) => categories.contains(cat))) {
        return false;
      }
      if (country.isNotEmpty && c.country != country) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<ChannelModel>> channelsByCountry(String countryCode) async {
    final all = await channelCache.getCachedChannels(allowStale: true) ?? [];
    return all.where((c) => c.country == countryCode.toUpperCase()).toList();
  }
}
