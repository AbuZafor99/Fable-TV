class ApiConstants {
  ApiConstants._();

  // ── iptv-org GitHub CDN API (free, no auth, ~10k channels) ──────────
  static const String iptvOrgBase = 'https://iptv-org.github.io/api';

  // ── IPTV Union API (free tier, filterable by country/category) ──────
  static const String iptvUnionBase = 'https://iptvunion.com';

  // ── Bangladesh-focused community M3U playlists (BDIX-friendly) ──────
  static const String rawGithubBase = 'https://raw.githubusercontent.com';

  // ignore: library_private_types_in_public_api
  static _IptvOrgEndpoints get iptvOrg => const _IptvOrgEndpoints();
  // ignore: library_private_types_in_public_api
  static _IptvUnionEndpoints get iptvUnion => const _IptvUnionEndpoints();
  // ignore: library_private_types_in_public_api
  static _BdIptvEndpoints get bdIptv => const _BdIptvEndpoints();
}

class _IptvOrgEndpoints {
  const _IptvOrgEndpoints();
  static const _base = ApiConstants.iptvOrgBase;

  // GET → [{id, name, alt_names, network, country, categories,
  //          is_nsfw, launched, closed, replaced_by, website, logo}]
  String get channels => '$_base/channels.json';

  // GET → [{channel, feed, title, url, referrer, user_agent,
  //          quality, label, http_referrer, is_broken}]
  String get streams => '$_base/streams.json';

  // GET → [{id, name}]  e.g. {id:"news", name:"News"}
  String get categories => '$_base/categories.json';

  // GET → [{code, name, flag, languages, neighbours}]
  String get countries => '$_base/countries.json';

  // GET → [{code, name, native_name, rtl}]
  String get languages => '$_base/languages.json';
}

class _IptvUnionEndpoints {
  const _IptvUnionEndpoints();
  static const _base = ApiConstants.iptvUnionBase;

  // GET /api/player_api?categories=News&country=BD&limit=50&offset=0
  // Response: {success, total, count, channels:[{id,channelName,streamUrl,
  //             logo,language,country,categories,streamingType,streamType}]}
  String channels({
    String? category,
    String? country,
    String? language,
    String? name,
    int limit = 50,
    int offset = 0,
  }) {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (category != null) 'categories': category,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      if (name != null) 'name': name,
      'streamType': 'free',
      'streamingType': 'tv',
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_base/api/player_api?$query';
  }
}

class _BdIptvEndpoints {
  const _BdIptvEndpoints();
  static const _base = ApiConstants.rawGithubBase;

  // GET → M3U playlist (plain `#EXTINF:-1 ,Name` entries, no logos/groups)
  // https://github.com/Shadmanislam/bdiptv
  String get shadmanIslam => '$_base/Shadmanislam/bdiptv/master/BD%20IPTV.m3u';

  // GET → M3U playlist (tvg-logo / group-title attrs, BDIX-friendly)
  // https://github.com/abusaeeidx/Mrgify-BDIX-IPTV
  String get mrgifyBdix =>
      '$_base/abusaeeidx/Mrgify-BDIX-IPTV/main/playlist.m3u';
}
