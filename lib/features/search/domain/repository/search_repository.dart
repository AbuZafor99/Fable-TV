import '../../../home/data/models/channel_model.dart';

/// All filtering is done client-side on the cached channel list — no API calls.
abstract class SearchRepository {
  Future<List<ChannelModel>> searchChannels({
    required String query,
    List<String> categories = const [],
    String country = '',
  });

  Future<List<ChannelModel>> channelsByCountry(String countryCode);
}
