import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/base/base_controller.dart';
import '../../../../core/services/channel_cache_service.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/data/models/world_cup_channels.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../data/models/stream_model.dart';
import '../widgets/mini_player_overlay.dart';
import '../widgets/player_controls.dart';

class PlayerController extends BaseController {
  final ChannelCacheService _cacheService = Get.find();

  final Rx<ChannelModel?> channel = Rx<ChannelModel?>(null);
  final RxList<StreamModel> availableStreams = <StreamModel>[].obs;
  final RxInt currentStreamIndex = 0.obs;
  final RxBool isFullScreen = false.obs;
  final RxBool isMiniPlayer = false.obs;
  final RxBool showControls = true.obs;
  final RxBool isLocked = false.obs;
  final RxBool isPlaying = true.obs;
  final RxDouble volume = 1.0.obs;
  final RxDouble brightness = 0.5.obs;
  final RxBool isBuffering = false.obs;
  final RxBool isSwitchingServer = false.obs;
  final RxBool allServersFailed = false.obs;

  /// True while a stream URL is being resolved or the player has not yet
  /// produced its first frame, so the UI can show a loading indicator.
  final RxBool isLoading = true.obs;

  /// -10 / +10 while a seek-flash label is showing, 0 otherwise.
  final RxInt seekFlash = 0.obs;
  Timer? _seekFlashTimer;
  double _previousVolume = 1.0;

  // Mini player position (from the right/bottom edges).
  final RxDouble miniX = 16.0.obs;
  final RxDouble miniY = 96.0.obs;

  BetterPlayerController? betterPlayerController;
  Timer? _hideControlsTimer;
  OverlayEntry? _miniPlayerOverlay;

  // Channels (within the same country) already tried and skipped during the
  // current auto-skip cascade, so it doesn't loop back to a known-bad one.
  final Set<String> _skippedChannelIds = {};
  static const int _maxAutoSkipAttempts = 25;

  Future<void> init(ChannelModel ch, {bool isAutoSkip = false}) async {
    closeMiniPlayer();
    if (!isAutoSkip) _skippedChannelIds.clear();
    channel.value = ch;
    allServersFailed.value = false;
    isSwitchingServer.value = false;
    isLoading.value = true;
    currentStreamIndex.value = 0;
    showControls.value = true;
    isLocked.value = false;

    final streams = List<StreamModel>.from(
        await _cacheService.getStreamsForChannel(ch.id));
    if (streams.isEmpty && (ch.streamUrl ?? '').isNotEmpty) {
      streams.add(StreamModel(channelId: ch.id, url: ch.streamUrl!));
    }
    for (final altUrl in worldCupAlternateStreams[ch.id] ?? const []) {
      streams.add(StreamModel(channelId: ch.id, url: altUrl));
    }
    availableStreams.assignAll(streams);
    if (availableStreams.isEmpty) {
      await _autoSkipToNextChannel();
      return;
    }

    await WakelockPlus.enable();
    await _readSystemLevels();
    _setupPlayer(availableStreams.first);
    startHideControlsTimer();
  }

  List<ChannelModel> _countryChannels(String country) {
    if (country.isEmpty || !Get.isRegistered<HomeController>()) return const [];
    return Get.find<HomeController>()
        .allChannels
        .where((c) => c.country == country)
        .toList();
  }

  /// Moves on to the next channel when the current one has no working
  /// stream, skipping channels already tried so it can't loop forever.
  /// Prefers a channel from the same country first, then falls back to any
  /// other channel in the catalog. Falls back to the "no working stream"
  /// error once every nearby channel (and the wider catalog) has been tried.
  Future<void> _autoSkipToNextChannel() async {
    final ch = channel.value;
    if (ch == null) {
      allServersFailed.value = true;
      isLoading.value = false;
      return;
    }
    _skippedChannelIds.add(ch.id);

    final next = _skippedChannelIds.length <= _maxAutoSkipAttempts
        ? _nextCandidateChannel(ch)
        : null;

    if (next == null) {
      allServersFailed.value = true;
      isLoading.value = false;
      _skippedChannelIds.clear();
      return;
    }

    showToast('${ch.name} is unavailable, switching to ${next.name}');
    await init(next, isAutoSkip: true);
  }

  /// Next untried channel for the auto-skip cascade: same-country channels
  /// (cyclically, starting after [ch]) first, then any other channel in the
  /// catalog as a last resort. Featured World Cup channels are an exception —
  /// if one fails, only cycle through other World Cup channels so playback
  /// never jumps to an unrelated channel.
  ChannelModel? _nextCandidateChannel(ChannelModel ch) {
    if (Get.isRegistered<HomeController>()) {
      final worldCupChannels = Get.find<HomeController>().fifaWorldCupChannels;
      final worldCupIndex = worldCupChannels.indexWhere((c) => c.id == ch.id);
      if (worldCupIndex != -1) {
        for (var i = 1; i <= worldCupChannels.length; i++) {
          final candidate =
              worldCupChannels[(worldCupIndex + i) % worldCupChannels.length];
          if (!_skippedChannelIds.contains(candidate.id)) return candidate;
        }
        return null;
      }
    }

    final countryList = _countryChannels(ch.country);
    final currentIndex = countryList.indexWhere((c) => c.id == ch.id);
    if (currentIndex != -1) {
      for (var i = 1; i <= countryList.length; i++) {
        final candidate = countryList[(currentIndex + i) % countryList.length];
        if (!_skippedChannelIds.contains(candidate.id)) return candidate;
      }
    }

    if (Get.isRegistered<HomeController>()) {
      for (final candidate in Get.find<HomeController>().allChannels) {
        if (!_skippedChannelIds.contains(candidate.id)) return candidate;
      }
    }
    return null;
  }

  Future<void> _readSystemLevels() async {
    try {
      brightness.value = await ScreenBrightness().current;
    } catch (e) {
      dPrint('Could not read brightness: $e');
    }
    try {
      VolumeController().showSystemUI = false;
      volume.value = await VolumeController().getVolume();
    } catch (e) {
      dPrint('Could not read volume: $e');
    }
  }

  BetterPlayerDataSource _dataSourceFor(StreamModel stream) {
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      stream.url,
      liveStream: true,
      headers: {
        if (stream.userAgent != null) 'User-Agent': stream.userAgent!,
        if (stream.referrer != null) 'Referer': stream.referrer!,
      },
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 2000,
        maxBufferMs: 8000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );
  }

  void _setupPlayer(StreamModel stream) {
    final dataSource = _dataSourceFor(stream);
    if (betterPlayerController == null) {
      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          fit: BoxFit.contain,
          autoDispose: false,
          handleLifecycle: false,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            playerTheme: BetterPlayerTheme.custom,
            customControlsBuilder: (_, __, ___) => const PlayerControls(),
          ),
        ),
        betterPlayerDataSource: dataSource,
      );
      betterPlayerController!.addEventsListener(_onPlayerEvent);
    } else {
      betterPlayerController!.setupDataSource(dataSource);
    }
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.bufferingStart:
        isBuffering.value = true;
        break;
      case BetterPlayerEventType.bufferingEnd:
        isBuffering.value = false;
        isLoading.value = false;
        break;
      case BetterPlayerEventType.play:
        isPlaying.value = true;
        isLoading.value = false;
        // Played successfully, so clear the skip history: a previously
        // skipped channel may have just been a transient failure.
        _skippedChannelIds.clear();
        break;
      case BetterPlayerEventType.pause:
        isPlaying.value = false;
        break;
      case BetterPlayerEventType.setupDataSource:
        isSwitchingServer.value = false;
        break;
      case BetterPlayerEventType.exception:
        dPrint('Player exception on server ${currentStreamIndex.value + 1}');
        tryNextServer();
        break;
      default:
        break;
    }
  }

  void tryNextServer() {
    if (currentStreamIndex.value < availableStreams.length - 1) {
      currentStreamIndex.value++;
      showToast('Trying server ${currentStreamIndex.value + 1}...');
      isSwitchingServer.value = true;
      betterPlayerController
          ?.setupDataSource(_dataSourceFor(availableStreams[currentStreamIndex.value]));
    } else {
      _autoSkipToNextChannel();
    }
  }

  void switchServer(int index) {
    if (index < 0 || index >= availableStreams.length) return;
    currentStreamIndex.value = index;
    allServersFailed.value = false;
    isSwitchingServer.value = true;
    betterPlayerController?.setupDataSource(_dataSourceFor(availableStreams[index]));
  }

  Future<void> retry() async {
    final ch = channel.value;
    if (ch != null) await init(ch);
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      betterPlayerController?.pause();
    } else {
      betterPlayerController?.play();
    }
  }

  void toggleFullScreen() {
    isFullScreen.toggle();
    if (isFullScreen.value) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _restoreSystemUi();
    }
  }

  void toggleLock() {
    isLocked.toggle();
    if (!isLocked.value) startHideControlsTimer();
  }

  void _restoreSystemUi() {
    // portraitDown is rejected on notched iPhones and makes iOS refuse the
    // whole orientation request, leaving the screen stuck in landscape.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ── Mini player (floats above all routes via the root Overlay) ───────

  void showMiniPlayer(BuildContext context) {
    if (isMiniPlayer.value || betterPlayerController == null) return;
    if (isFullScreen.value) toggleFullScreen();
    isMiniPlayer.value = true;
    _miniPlayerOverlay = OverlayEntry(
      builder: (_) => const MiniPlayerOverlay(),
    );
    Overlay.of(context, rootOverlay: true).insert(_miniPlayerOverlay!);
    WakelockPlus.enable();
    Get.back();
  }

  void closeMiniPlayer({bool stopPlayback = false}) {
    _miniPlayerOverlay?.remove();
    _miniPlayerOverlay = null;
    isMiniPlayer.value = false;
    if (stopPlayback) stopAndRelease();
  }

  // ── Volume / brightness ──────────────────────────────────────────────

  void setVolume(double v) {
    final clamped = v.clamp(0.0, 1.0);
    try {
      VolumeController().setVolume(clamped);
    } catch (e) {
      dPrint('setVolume failed: $e');
    }
    betterPlayerController?.setVolume(clamped);
    volume.value = clamped;
  }

  void setBrightness(double b) {
    final clamped = b.clamp(0.0, 1.0);
    try {
      ScreenBrightness().setScreenBrightness(clamped);
    } catch (e) {
      dPrint('setBrightness failed: $e');
    }
    brightness.value = clamped;
  }

  void toggleMute() {
    if (volume.value > 0) {
      _previousVolume = volume.value;
      setVolume(0);
    } else {
      setVolume(_previousVolume > 0 ? _previousVolume : 1.0);
    }
  }

  /// Seeks ±[seconds] and briefly shows a "+10s"/"-10s" flash label.
  void seek(int seconds) {
    final position = betterPlayerController?.videoPlayerController?.value.position;
    if (position != null) {
      var target = position + Duration(seconds: seconds);
      if (target < Duration.zero) target = Duration.zero;
      betterPlayerController?.seekTo(target);
    }
    seekFlash.value = seconds;
    _seekFlashTimer?.cancel();
    _seekFlashTimer = Timer(const Duration(milliseconds: 600), () {
      seekFlash.value = 0;
    });
    startHideControlsTimer();
  }

  // ── Controls visibility ──────────────────────────────────────────────

  void toggleControls() {
    if (isLocked.value) return;
    showControls.toggle();
    if (showControls.value) startHideControlsTimer();
  }

  void startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      showControls.value = false;
    });
  }

  /// Stops playback and releases the video surface; called when the player
  /// screen is dismissed without minimizing to PiP.
  void stopAndRelease() {
    _hideControlsTimer?.cancel();
    betterPlayerController?.removeEventsListener(_onPlayerEvent);
    betterPlayerController?.dispose(forceDispose: true);
    betterPlayerController = null;
    channel.value = null;
    availableStreams.clear();
    if (isFullScreen.value) _restoreSystemUi();
    isFullScreen.value = false;
    WakelockPlus.disable();
    try {
      ScreenBrightness().resetScreenBrightness();
    } catch (_) {}
  }

  @override
  void onClose() {
    _seekFlashTimer?.cancel();
    closeMiniPlayer();
    stopAndRelease();
    super.onClose();
  }
}
