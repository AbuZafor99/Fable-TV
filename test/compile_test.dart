import 'package:flutter_test/flutter_test.dart';
import 'package:streamworld/core/utils/m3u_parser.dart';
import 'package:streamworld/features/home/data/models/channel_model.dart';
import 'package:streamworld/features/home/data/models/country_model.dart';
import 'package:streamworld/features/player/data/models/stream_model.dart';
import 'package:streamworld/main.dart';

void main() {
  test('app and dependencies compile', () {
    expect(const StreamWorldApp(), isA<StreamWorldApp>());
  });

  test('channel model parses iptv-org shape and filters flags', () {
    final channel = ChannelModel.fromIptvOrg(const {
      'id': 'BBCOne.uk',
      'name': 'BBC One',
      'alt_names': ['BBC 1'],
      'country': 'GB',
      'categories': ['general'],
      'is_nsfw': false,
      'logo': 'https://example.com/logo.png',
    });
    expect(channel.id, 'BBCOne.uk');
    expect(channel.countryFlag, '🇬🇧');
    expect(channel.altNames, contains('BBC 1'));

    final restored = ChannelModel.fromJson(channel.toJson());
    expect(restored, channel);
  });

  test('stream model parses iptv-org shape', () {
    final stream = StreamModel.fromIptvOrg(const {
      'channel': 'BBCOne.uk',
      'url': 'https://example.com/stream.m3u8',
      'quality': '720p',
      'user_agent': 'Mozilla/5.0',
    });
    expect(stream.channelId, 'BBCOne.uk');
    expect(stream.isBroken, isFalse);
  });

  test('nearest centroid resolves map taps offline', () {
    expect(CountryModel.nearestCountryCode(23.7, 90.3), 'BD');
    expect(CountryModel.nearestCountryCode(51.5, -0.1), 'GB');
    expect(CountryModel.nearestCountryCode(0, -150), isNull); // mid-Pacific
  });

  test('m3u parser handles bare EXTINF entries (bdiptv)', () {
    const playlist = '#EXTM3U\n'
        '#EXTINF:-1 ,Gazi tv\n'
        'http://itpolly.iptv.digijadoo.net/live/gazi_tv/chunks.m3u8\n'
        '#EXTINF:-1 ,Maasranga\n'
        'https://itpolly.iptv.digijadoo.net/live/maasranga/chunks.m3u8\n';

    final channels = parseM3uPlaylist(playlist, idPrefix: 'bd-', country: 'BD');

    expect(channels, hasLength(2));
    expect(channels.first.id, 'bd-gazi-tv');
    expect(channels.first.name, 'Gazi tv');
    expect(channels.first.country, 'BD');
    expect(channels.first.countryFlag, '🇧🇩');
    expect(channels.first.streamUrl,
        'http://itpolly.iptv.digijadoo.net/live/gazi_tv/chunks.m3u8');
  });

  test('m3u parser handles extended EXTINF entries (Mrgify BDIX)', () {
    const playlist = '#EXTM3U\n'
        '#EXTINF:-1 group-title="Bangla" tvg-id="MAASRANGA.bd" '
        'tvg-logo="https://example.com/maasranga.png",MAASRANGA HD\n'
        'http://mtv.sunplex.live/MAASRANGA-TV/index.m3u8\n';

    final channels = parseM3uPlaylist(playlist, idPrefix: 'bd-', country: 'BD');

    expect(channels, hasLength(1));
    final channel = channels.single;
    expect(channel.id, 'bd-maasranga-hd');
    expect(channel.name, 'MAASRANGA HD');
    expect(channel.logoUrl, 'https://example.com/maasranga.png');
    expect(channel.categories, ['Bangla']);
    expect(channel.streamUrl, 'http://mtv.sunplex.live/MAASRANGA-TV/index.m3u8');
  });
}
