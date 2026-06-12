import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/home/data/models/category_model.dart';
import '../../features/home/data/models/channel_model.dart';
import '../../features/home/data/models/country_model.dart';
import '../../features/player/data/models/stream_model.dart';
import '../constants/cache_constants.dart';
import '../utils/debug_print.dart';

/// Hive-based, JSON-string storage (no TypeAdapter codegen needed).
/// Large payloads are decoded off the main isolate via [compute].
class ChannelCacheService extends GetxService {
  Box<String> get _channelsBox => Hive.box<String>(CacheConstants.channelsBox);
  Box<String> get _streamsBox => Hive.box<String>(CacheConstants.streamsBox);
  Box<String> get _recentBox => Hive.box<String>(CacheConstants.recentBox);

  Map<String, List<StreamModel>>? _streamIndexMemo;

  // ── Channel cache ────────────────────────────────────────────────────

  Future<void> cacheChannels(List<ChannelModel> channels) async {
    final encoded =
        await compute(_encodeJsonList, channels.map((c) => c.toJson()).toList());
    await _channelsBox.put(CacheConstants.channelsDataKey, encoded);
    await _channelsBox.put(
        CacheConstants.channelsUpdatedAtKey, DateTime.now().toIso8601String());
  }

  /// Returns null when empty, or — unless [allowStale] — when older than TTL.
  Future<List<ChannelModel>?> getCachedChannels({bool allowStale = false}) async {
    final raw = _channelsBox.get(CacheConstants.channelsDataKey);
    if (raw == null || raw.isEmpty) return null;
    if (!allowStale && isCacheStale(CacheConstants.channelsUpdatedAtKey)) return null;
    try {
      final list = await compute(_decodeJsonList, raw);
      return list.map(ChannelModel.fromJson).toList();
    } catch (e) {
      dPrint('Failed to decode cached channels: $e');
      return null;
    }
  }

  // ── Category / country cache ─────────────────────────────────────────

  Future<void> cacheCategories(List<CategoryModel> categories) async {
    await _channelsBox.put(CacheConstants.categoriesDataKey,
        jsonEncode(categories.map((c) => c.toJson()).toList()));
    await _channelsBox.put(
        CacheConstants.categoriesUpdatedAtKey, DateTime.now().toIso8601String());
  }

  List<CategoryModel>? getCachedCategories({bool allowStale = false}) {
    final raw = _channelsBox.get(CacheConstants.categoriesDataKey);
    if (raw == null || raw.isEmpty) return null;
    if (!allowStale && isCacheStale(CacheConstants.categoriesUpdatedAtKey)) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheCountries(List<CountryModel> countries) async {
    await _channelsBox.put(CacheConstants.countriesDataKey,
        jsonEncode(countries.map((c) => c.toJson()).toList()));
    await _channelsBox.put(
        CacheConstants.countriesUpdatedAtKey, DateTime.now().toIso8601String());
  }

  List<CountryModel>? getCachedCountries({bool allowStale = false}) {
    final raw = _channelsBox.get(CacheConstants.countriesDataKey);
    if (raw == null || raw.isEmpty) return null;
    if (!allowStale && isCacheStale(CacheConstants.countriesUpdatedAtKey)) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Streams cache / index: channelId → [StreamModel] ─────────────────

  Future<void> cacheStreams(List<StreamModel> streams) => buildStreamIndex(streams);

  Future<List<StreamModel>?> getCachedStreams() async {
    final index = await _loadStreamIndex();
    if (index == null) return null;
    return index.values.expand((s) => s).toList();
  }

  /// Groups the full stream list by channel id and persists the index, so
  /// per-channel lookups never rescan the 30k-item list.
  Future<void> buildStreamIndex(List<StreamModel> streams) async {
    final encoded = await compute(_buildAndEncodeStreamIndex, streams);
    await _streamsBox.put(CacheConstants.streamIndexKey, encoded);
    await _streamsBox.put(
        CacheConstants.streamsUpdatedAtKey, DateTime.now().toIso8601String());
    _streamIndexMemo = null;
  }

  Future<List<String>> getStreamUrlsForChannel(String channelId) async {
    final streams = await getStreamsForChannel(channelId);
    return streams.map((s) => s.url).toList();
  }

  Future<List<StreamModel>> getStreamsForChannel(String channelId) async {
    final index = await _loadStreamIndex();
    return index?[channelId] ?? const [];
  }

  bool get hasStreamIndex =>
      (_streamsBox.get(CacheConstants.streamIndexKey) ?? '').isNotEmpty;

  Future<Map<String, List<StreamModel>>?> _loadStreamIndex() async {
    if (_streamIndexMemo != null) return _streamIndexMemo;
    final raw = _streamsBox.get(CacheConstants.streamIndexKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      _streamIndexMemo = await compute(_decodeStreamIndex, raw);
      return _streamIndexMemo;
    } catch (e) {
      dPrint('Failed to decode stream index: $e');
      return null;
    }
  }

  // ── Recent channels (max 10) ─────────────────────────────────────────

  Future<void> addToRecent(ChannelModel channel) async {
    final recent = await getRecentChannels();
    recent.removeWhere((c) => c.id == channel.id);
    recent.insert(0, channel);
    final capped = recent.take(CacheConstants.maxRecentChannels).toList();
    await _recentBox.put(CacheConstants.recentChannelsKey,
        jsonEncode(capped.map((c) => c.toJson()).toList()));
  }

  Future<List<ChannelModel>> getRecentChannels() async {
    final raw = _recentBox.get(CacheConstants.recentChannelsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Favorites ────────────────────────────────────────────────────────

  Future<List<ChannelModel>> getFavoriteChannels() async {
    final raw = _recentBox.get(CacheConstants.favoriteChannelsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the new favorite state of the channel.
  Future<bool> toggleFavorite(ChannelModel channel) async {
    final favorites = await getFavoriteChannels();
    final wasFavorite = favorites.any((c) => c.id == channel.id);
    if (wasFavorite) {
      favorites.removeWhere((c) => c.id == channel.id);
    } else {
      favorites.insert(0, channel);
    }
    await _recentBox.put(CacheConstants.favoriteChannelsKey,
        jsonEncode(favorites.map((c) => c.toJson()).toList()));
    return !wasFavorite;
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  bool isCacheStale(String updatedAtKey) {
    final box = updatedAtKey == CacheConstants.streamsUpdatedAtKey
        ? _streamsBox
        : _channelsBox;
    final raw = box.get(updatedAtKey);
    if (raw == null) return true;
    final updatedAt = DateTime.tryParse(raw);
    if (updatedAt == null) return true;
    return DateTime.now().difference(updatedAt) > CacheConstants.cacheTtl;
  }

  /// The [CacheConstants.dataVersion] that the currently cached country and
  /// channel data was produced under (0 if never set).
  int get cachedDataVersion =>
      int.tryParse(_channelsBox.get(CacheConstants.dataVersionKey) ?? '') ?? 0;

  Future<void> markDataVersionCurrent() =>
      _channelsBox.put(CacheConstants.dataVersionKey, '${CacheConstants.dataVersion}');

  Future<void> clearAll() async {
    _streamIndexMemo = null;
    await _channelsBox.clear();
    await _streamsBox.clear();
    await _recentBox.clear();
  }
}

// ── Isolate workers (must be top-level for compute) ─────────────────────

String _encodeJsonList(List<Map<String, dynamic>> list) => jsonEncode(list);

List<Map<String, dynamic>> _decodeJsonList(String raw) =>
    (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

String _buildAndEncodeStreamIndex(List<StreamModel> streams) {
  final index = <String, List<Map<String, dynamic>>>{};
  for (final s in streams) {
    if (s.channelId.isEmpty || s.url.isEmpty) continue;
    index.putIfAbsent(s.channelId, () => []).add(s.toJson());
  }
  return jsonEncode(index);
}

Map<String, List<StreamModel>> _decodeStreamIndex(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return json.map((channelId, list) => MapEntry(
        channelId,
        (list as List)
            .map((e) => StreamModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      ));
}
