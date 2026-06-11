import 'dart:convert';

import '../../features/home/data/models/channel_model.dart';

final RegExp _attrPattern = RegExp(r'([a-zA-Z0-9_-]+)="([^"]*)"');

/// Parses a basic M3U/M3U8 IPTV playlist into [ChannelModel]s.
///
/// Supports both bare `#EXTINF:-1 ,Name` entries and extended entries with
/// `tvg-logo` / `group-title` attributes. Each entry's stream URL is stored
/// directly on [ChannelModel.streamUrl] since these playlists bundle the
/// channel and its stream together (unlike the iptv-org channels/streams
/// split).
List<ChannelModel> parseM3uPlaylist(
  String content, {
  required String idPrefix,
  String country = '',
}) {
  final channels = <ChannelModel>[];
  String? pendingName;
  String? pendingLogo;
  List<String> pendingCategories = const [];

  for (final rawLine in const LineSplitter().convert(content)) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('#EXTINF')) {
      final commaIndex = line.lastIndexOf(',');
      if (commaIndex == -1) continue;
      final name = line.substring(commaIndex + 1).trim();
      if (name.isEmpty) {
        pendingName = null;
        continue;
      }
      final attrsPart = line.substring(0, commaIndex);
      final attrs = <String, String>{
        for (final m in _attrPattern.allMatches(attrsPart))
          m.group(1)!.toLowerCase(): m.group(2)!,
      };
      pendingName = name;
      pendingLogo = attrs['tvg-logo'];
      final group = attrs['group-title']?.trim();
      pendingCategories = (group != null && group.isNotEmpty) ? [group] : const [];
      continue;
    }

    if (line.startsWith('#')) continue; // other directives, e.g. #EXTVLCOPT
    if (pendingName == null) continue;

    channels.add(ChannelModel(
      id: '$idPrefix${_slugify(pendingName)}',
      name: pendingName,
      country: country,
      countryFlag: country.isNotEmpty ? flagFromCountryCode(country) : '',
      categories: pendingCategories,
      logoUrl: pendingLogo ?? '',
      streamUrl: line,
    ));

    pendingName = null;
    pendingLogo = null;
    pendingCategories = const [];
  }

  return channels;
}

String _slugify(String input) => input
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
