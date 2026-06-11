import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/network_success.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_result.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../../core/utils/m3u_parser.dart';
import '../../domain/repository/channel_repository.dart';
import '../models/category_model.dart';
import '../models/channel_model.dart';
import '../models/country_model.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final ApiClient apiClient;

  ChannelRepositoryImpl({required this.apiClient});

  @override
  Future<NetworkResult<List<ChannelModel>>> fetchAllChannels() async {
    final base = await _fetchBaseChannels();
    final bdChannels = await _fetchBdChannels();
    if (bdChannels.isEmpty) return base;
    return base.map((success) => NetworkSuccess(
          data: [...success.data, ...bdChannels],
          statusCode: success.statusCode,
        ));
  }

  Future<NetworkResult<List<ChannelModel>>> _fetchBaseChannels() async {
    final result = await apiClient.getPlain(ApiConstants.iptvOrg.channels);
    return result.fold(
      (failure) {
        dPrint('iptv-org unreachable (${failure.message}), trying IPTV Union');
        return _fetchFromIptvUnion();
      },
      (success) async {
        // ~10k items: decode off the main isolate.
        final channels = await compute(parseIptvOrgChannels, success.data);
        return Right(NetworkSuccess(data: channels, statusCode: success.statusCode));
      },
    );
  }

  /// Fetches Bangladesh-focused community playlists (BDIX-friendly local
  /// streams not present in the iptv-org catalogue) and tags them as `BD`
  /// channels so they join the Bangladesh country group.
  Future<List<ChannelModel>> _fetchBdChannels() async {
    final results = await Future.wait([
      apiClient.getPlain(ApiConstants.bdIptv.shadmanIslam),
      apiClient.getPlain(ApiConstants.bdIptv.mrgifyBdix),
    ]);

    final channels = <String, ChannelModel>{};
    for (final result in results) {
      result.fold(
        (failure) => dPrint('BD playlist unreachable: ${failure.message}'),
        (success) {
          final parsed = parseM3uPlaylist(success.data, idPrefix: 'bd-', country: 'BD');
          for (final c in parsed) {
            channels[c.id] = c;
          }
        },
      );
    }
    return channels.values.toList();
  }

  Future<NetworkResult<List<ChannelModel>>> _fetchFromIptvUnion() async {
    final url = ApiConstants.iptvUnion.channels(limit: 500);
    final result = await apiClient.get(url);
    return result.map((success) {
      final json = success.data is String
          ? jsonDecode(success.data as String)
          : success.data;
      final list = (json is Map<String, dynamic> ? json['channels'] : null) as List? ?? [];
      final channels = list
          .map((e) => ChannelModel.fromIptvUnion(e as Map<String, dynamic>))
          .where((c) => !c.isNsfw && c.id.isNotEmpty)
          .toList();
      return NetworkSuccess(data: channels, statusCode: success.statusCode);
    });
  }

  @override
  Future<NetworkResult<List<CategoryModel>>> fetchCategories() async {
    final result = await apiClient.get(ApiConstants.iptvOrg.categories);
    return result.map((success) {
      final list = success.data as List? ?? [];
      final categories = list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .where((c) => c.id != 'xxx')
          .toList();
      return NetworkSuccess(data: categories, statusCode: success.statusCode);
    });
  }

  @override
  Future<NetworkResult<List<CountryModel>>> fetchCountries() async {
    final result = await apiClient.get(ApiConstants.iptvOrg.countries);
    return result.map((success) {
      final list = success.data as List? ?? [];
      final countries = list
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return NetworkSuccess(data: countries, statusCode: success.statusCode);
    });
  }
}

// Top-level so it can run in a background isolate via compute.
List<ChannelModel> parseIptvOrgChannels(String body) {
  final list = jsonDecode(body) as List;
  return list
      .map((e) => ChannelModel.fromIptvOrg(e as Map<String, dynamic>))
      .where((c) => !c.isNsfw && c.id.isNotEmpty)
      .toList();
}
