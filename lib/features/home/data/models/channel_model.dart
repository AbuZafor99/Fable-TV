import 'package:equatable/equatable.dart';

import 'country_model.dart';

class ChannelModel extends Equatable {
  final String id;
  final String name;
  final List<String> altNames;
  final String country; // ISO 3166-1 alpha-2 e.g. "BD"
  final String countryName; // filled via countries lookup "Bangladesh"
  final String countryFlag; // emoji "🇧🇩" filled via lookup
  final List<String> categories;
  final String logoUrl;
  final String? website;
  final bool isNsfw;
  final String? network;
  final String? streamUrl; // populated after joining with streams.json
  final String? quality; // "1080p" / "720p" / "SD" / null

  const ChannelModel({
    required this.id,
    required this.name,
    this.altNames = const [],
    required this.country,
    this.countryName = '',
    this.countryFlag = '',
    this.categories = const [],
    this.logoUrl = '',
    this.website,
    this.isNsfw = false,
    this.network,
    this.streamUrl,
    this.quality,
  });

  factory ChannelModel.fromIptvOrg(Map<String, dynamic> json) {
    final code = (json['country'] as String?) ?? '';
    return ChannelModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      altNames: _stringList(json['alt_names']),
      country: code,
      countryFlag: flagFromCountryCode(code),
      categories: _stringList(json['categories']),
      logoUrl: (json['logo'] as String?) ?? '',
      website: json['website'] as String?,
      isNsfw: json['is_nsfw'] == true,
      network: json['network'] as String?,
    );
  }

  factory ChannelModel.fromIptvUnion(Map<String, dynamic> json) {
    final code = ((json['country'] as String?) ?? '').toUpperCase();
    return ChannelModel(
      id: '${json['id'] ?? json['channelName'] ?? ''}',
      name: (json['channelName'] as String?) ?? '',
      country: code,
      countryFlag: flagFromCountryCode(code),
      categories: _stringList(json['categories']),
      logoUrl: (json['logo'] as String?) ?? '',
      streamUrl: json['streamUrl'] as String?,
    );
  }

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      altNames: _stringList(json['altNames']),
      country: (json['country'] as String?) ?? '',
      countryName: (json['countryName'] as String?) ?? '',
      countryFlag: (json['countryFlag'] as String?) ?? '',
      categories: _stringList(json['categories']),
      logoUrl: (json['logoUrl'] as String?) ?? '',
      website: json['website'] as String?,
      isNsfw: json['isNsfw'] == true,
      network: json['network'] as String?,
      streamUrl: json['streamUrl'] as String?,
      quality: json['quality'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'altNames': altNames,
        'country': country,
        'countryName': countryName,
        'countryFlag': countryFlag,
        'categories': categories,
        'logoUrl': logoUrl,
        'website': website,
        'isNsfw': isNsfw,
        'network': network,
        'streamUrl': streamUrl,
        'quality': quality,
      };

  ChannelModel copyWith({
    String? countryName,
    String? countryFlag,
    String? streamUrl,
    String? quality,
  }) {
    return ChannelModel(
      id: id,
      name: name,
      altNames: altNames,
      country: country,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      categories: categories,
      logoUrl: logoUrl,
      website: website,
      isNsfw: isNsfw,
      network: network,
      streamUrl: streamUrl ?? this.streamUrl,
      quality: quality ?? this.quality,
    );
  }

  ChannelModel withCountry(CountryModel? c) {
    if (c == null) return this;
    return copyWith(countryName: c.name, countryFlag: c.flag);
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is List) return raw.map((e) => '$e').toList();
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).toList();
    }
    return const [];
  }

  @override
  List<Object?> get props => [id, name, country, streamUrl, quality];
}

/// Builds the emoji flag from an ISO alpha-2 code via regional indicators.
String flagFromCountryCode(String code) {
  if (code.length != 2) return '';
  return code
      .toUpperCase()
      .codeUnits
      .map((c) => String.fromCharCode(0x1F1A5 + c))
      .join();
}
