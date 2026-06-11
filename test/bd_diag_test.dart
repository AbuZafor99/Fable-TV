import 'package:flutter_test/flutter_test.dart';
import 'package:streamworld/core/network/api_client.dart';
import 'package:streamworld/features/home/data/repositories/channel_repository_impl.dart';

void main() {
  test('diagnose BD channel + country pipeline', () async {
    final repo = ChannelRepositoryImpl(apiClient: ApiClient());

    final countriesResult = await repo.fetchCountries();
    final countries = countriesResult.fold((f) => throw f, (s) => s.data);
    final bdCountry = countries.where((c) => c.code == 'BD').toList();
    print('BD country entry: $bdCountry');
    print('BD hasCoordinates: ${bdCountry.isNotEmpty ? bdCountry.first.hasCoordinates : "N/A"}');

    final channelsResult = await repo.fetchAllChannels();
    final channels = channelsResult.fold((f) => throw f, (s) => s.data);
    print('total channels: ${channels.length}');
    final bdChannels = channels.where((c) => c.country == 'BD').toList();
    print('BD channels: ${bdChannels.length}');
    for (final c in bdChannels.take(10)) {
      print('  ${c.id} | ${c.name} | stream=${c.streamUrl}');
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
