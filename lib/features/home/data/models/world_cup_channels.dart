import 'channel_model.dart';

/// Hand-picked FIFA World Cup / FIFA+ live feeds for the home screen's
/// "Featured" section. Used directly as `streamUrl` (no stream-index lookup
/// needed) since these aren't part of the iptv-org catalogue.
const List<ChannelModel> worldCupFeaturedChannels = [
  ChannelModel(
    id: 'wc-fifaplus-en',
    name: 'FIFA+ English',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://a62dad94.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWV1X0ZJRkFQbHVzRW5nbGlzaF9ITFM/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-es',
    name: 'FIFA+ Spanish',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://d63fabad.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWVzX0ZJRkFQbHVzU3BhbmlzaF9ITFM/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-fr',
    name: 'FIFA+ French',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://37b4c228.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWZyX0ZJRkFQbHVzRnJlbmNoX0hMUw/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-de',
    name: 'FIFA+ German',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://4397879b.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWRlX0ZJRkFQbHVzR2VybWFuX0hMUw/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-it',
    name: 'FIFA+ Italian',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://5d95f7d7.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWl0X0ZJRkFQbHVzSXRhbGlhbl9ITFM/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-es-mx',
    name: 'FIFA+ Spanish (LG)',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://6c849fb3.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/TEctbXhfRklGQVBsdXNTcGFuaXNoLTFfSExT/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifaplus-pt',
    name: 'FIFA+ Portuguese',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://e3be9ac5.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/TEctYnJfRklGQVBsdXNQb3J0dWd1ZXNlX0hMUw/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-fifa-tv',
    name: 'FIFA',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://d2w9q46ikgrcwx.cloudfront.net/v1/master/3722c60a815c199d9c0ef36c5b73da68a62b09d1/cc-of5cbk3sav3w5/v1/sysdata_s_p_a_fifa_7/samsungheadend_us/latest/main/hls/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-caze-tv',
    name: 'Caze TV',
    country: 'BR',
    countryFlag: '🇧🇷',
    categories: ['sports'],
    streamUrl:
        'https://dfr80qz435crc.cloudfront.net/MNOP/Amagi/Caze/Caze_TV_BR/Caze_TV.m3u8',
  ),
  ChannelModel(
    id: 'wc-bein-sports-xtra',
    name: 'beIN Sports Xtra',
    country: '',
    categories: ['sports'],
    streamUrl:
        'https://amg01334-amg01334c2-freelivesports-emea-6791.playouts.now.amagi.tv/playlist/amg01334-beinxtra-beinxtrausapp-freelivesportsemea/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-tyc-sports-studio',
    name: 'TyC Sports Studio',
    country: 'AR',
    countryFlag: '🇦🇷',
    categories: ['sports'],
    streamUrl:
        'https://amg26268-amg26268c14-freelivesports-emea-10267.playouts.now.amagi.tv/ts-us-e2-n2/playlist/amg26268-sportsstudio-tycsports-freelivesportsemea/playlist.m3u8',
  ),
  ChannelModel(
    id: 'wc-bein-sports-espanol',
    name: 'beIN Sports en Español',
    country: '',
    categories: ['sports'],
    streamUrl: 'https://bein-esp-xumo.amagi.tv/playlistR1080p.m3u8',
  ),
  ChannelModel(
    id: 'wc-ptv-sports',
    name: 'PTV Sports',
    country: 'PK',
    countryFlag: '🇵🇰',
    categories: ['sports'],
    streamUrl: 'https://tvsen5.aynaott.com/PtvSports/index.m3u8',
  ),
  ChannelModel(
    id: 'wc-world-sports-1',
    name: 'World Sports 1',
    country: '',
    categories: ['sports'],
    streamUrl: 'https://andro.226503.xyz/checklist/androstreamlivebs1.m3u8',
  ),
];

/// Alternate-quality/source URLs for some [worldCupFeaturedChannels],
/// appended to `availableStreams` as fallback servers so the in-player
/// "try next server" cascade can recover before skipping to a different
/// channel entirely.
const Map<String, List<String>> worldCupAlternateStreams = {
  'wc-fifaplus-fr': [
    'https://37b4c228.wurl.com/manifest/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWZyX0ZJRkFQbHVzRnJlbmNoX0hMUw/6f5437c5-e015-4754-8476-c8c6d27d3a55/1.m3u8',
  ],
  'wc-caze-tv': [
    'https://dfr80qz435crc.cloudfront.net/MNOP/Amagi/Caze/Caze_TV_BR/1080p-vtt/index.m3u8',
  ],
  'wc-bein-sports-xtra': [
    'https://amg01334-amg01334c2-freelivesports-emea-6791.playouts.now.amagi.tv/ts-eu-w1-n2/playlist/amg01334-beinxtra-beinxtrausapp-freelivesportsemea/cb553d1e786c678e9cd43d64d8ef41a3db2427fc087a8d6933fb4b926bc10f41f8eda29ab30fb02b04940fa73f4e380d4d1a9a4ace0362d7b66aa9515b7d121b9d81a20a99d94e5cd58d5d5173f7651b52f91016d6354b59f1dd3724c97db9700e16a82e6b553982f449de2e109add5f947e2d83b3dd7f39635a4ffc0c0bb4e207bcfae25a5bdb6ab3a5191e9c2e47e5d044d4d219edd6c95a9f15876ba31dcf94edde824187849760a154b232596aca1cf3f411065d74ccb8b84d7bf65329481959e7a796ed464ee92d217dcb8f003bf89d69aaa83688614dd0682184ac42ef4fa208ace00cd7c5007173335887be35452fa1eea1cadf3c25b475f2ade79f1c142358250a25983ea2470f3091f6ca5ee2a971c7e472d7e629753cb1b2889223a329b890f46087c685eb0eae1d082442170b871286926cd028e7a9c9a4060c53574da196548bd3970e702a62878357da0714aad3d0c3f6002fcf6c5b77e9639974362cf4743d2cda7caca56b25c9071a953938cc5d37ab4be8f779a6f095b6507bfdf5ef76d243a3f506dbfd07e94a395a09bcbb6c7c4d5e72ddeb295c64218d15aa8384b1373a01eaf6dff78f066b507744047ee488835fa8cef85b7a47916c77354b476dd16eb04ed00f4e0c2bbb7bf2bc1978807c4c0eeeb530505f2cdb889eb2c7ee8823917ac0c4e9363f313b30e4d364c5c81e07eb84c6bca4e8126dadfc330a0129b13710/39/1920x1080_4715744/index.m3u8',
  ],
  'wc-bein-sports-espanol': [
    'https://bein-esp-xumo.amagi.tv/playlistR720P.m3u8',
  ],
  'wc-ptv-sports': [
    'https://tvsen5.aynaott.com/PtvSports/index.m3u8?e=1779283784&u=78be6644-0a65-48ec-81a4-089ac65a2619&token=db1789e36c278bf538489fac263e0ffb',
  ],
};
