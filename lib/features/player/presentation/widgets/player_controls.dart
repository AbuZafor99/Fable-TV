import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/app_gradient.dart';
import '../../../../Theme/constants/app_colors.dart';
import '../controllers/player_controller.dart';
import 'server_selector_sheet.dart';

/// Custom controls overlay matching the design: top bar (back / title+meta /
/// cast / lock), side brightness+volume sliders, ±10s seek with seek-flash,
/// big play-pause, and a bottom LIVE bar with mute/server/PiP/fullscreen.
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    return Obx(() {
      // The mini player draws its own minimal chrome; the full control
      // surface doesn't fit in 166px.
      if (controller.isMiniPlayer.value) return const SizedBox.shrink();
      if (controller.isLocked.value) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.toggleLock,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: Colors.white70, size: 28),
                SizedBox(height: 8),
                Text(
                  'Tap to unlock',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }

      // better_player's controls subtree has no Material ancestor, which the
      // Sliders require.
      return Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.toggleControls,
          child: Stack(
            children: [
              if (controller.showControls.value) ...[
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: kPlayerOverlayGradient,
                      ),
                    ),
                  ),
                ),
                _topBar(controller, context),
                _sideSliders(controller),
                _centerControls(controller),
                _bottomBar(controller, context),
              ],
              if (controller.seekFlash.value != 0)
                _seekFlash(controller.seekFlash.value),
              if (controller.isSwitchingServer.value)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.42),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Switching server…',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _topBar(PlayerController controller, BuildContext context) {
    final ch = controller.channel.value;
    final metaParts = <String>[
      if (ch != null)
        ch.countryName.isNotEmpty ? ch.countryName : ch.country,
      if (ch?.quality != null) ch!.quality!,
    ];
    final meta = metaParts.where((e) => e.isNotEmpty).join(' · ');

    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          _OverlayButton(
            icon: controller.isFullScreen.value
                ? Icons.close_fullscreen_rounded
                : Icons.keyboard_arrow_down_rounded,
            onTap: () {
              if (controller.isFullScreen.value) {
                controller.toggleFullScreen();
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ch?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10.5,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _OverlayButton(
            icon: Icons.cast_rounded,
            onTap: () => controller.showToast('Casting not available yet'),
          ),
          const SizedBox(width: 8),
          _OverlayButton(
            icon: Icons.lock_open_rounded,
            onTap: controller.toggleLock,
          ),
        ],
      ),
    );
  }

  Widget _sideSliders(PlayerController controller) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SliderGroup(
              label: 'Brightness',
              value: controller.brightness.value,
              icon: Icons.wb_sunny_rounded,
              accent: TColors.warning,
              onChanged: controller.setBrightness,
            ),
            _SliderGroup(
              label: 'Volume',
              value: controller.volume.value,
              icon: controller.volume.value <= 0.001
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              accent: TColors.primary,
              onChanged: controller.setVolume,
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerControls(PlayerController controller) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OverlayButton(
            icon: Icons.replay_10_rounded,
            size: 50,
            iconSize: 24,
            onTap: () => controller.seek(-10),
          ),
          const SizedBox(width: 30),
          GestureDetector(
            onTap: () {
              controller.togglePlayPause();
              controller.startHideControlsTimer();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: Icon(
                controller.isPlaying.value
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(width: 30),
          _OverlayButton(
            icon: Icons.forward_10_rounded,
            size: 50,
            iconSize: 24,
            onTap: () => controller.seek(10),
          ),
        ],
      ),
    );
  }

  Widget _seekFlash(int seconds) {
    final label = seconds > 0 ? '+${seconds}s' : '${seconds}s';
    return Positioned(
      top: 0,
      bottom: 0,
      left: seconds < 0 ? 34 : null,
      right: seconds > 0 ? 34 : null,
      child: Center(
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(PlayerController controller, BuildContext context) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TColors.live,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: TColors.live, blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    height: 4,
                    child: Stack(
                      children: [
                        Container(color: Colors.white.withValues(alpha: 0.22)),
                        FractionallySizedBox(
                          widthFactor: 0.82,
                          child: Container(color: TColors.live),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _OverlayButton(
                icon: controller.volume.value <= 0.001
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                onTap: controller.toggleMute,
              ),
              if (controller.availableStreams.length > 1) ...[
                const SizedBox(width: 8),
                _OverlayButton(
                  icon: Icons.dns_rounded,
                  onTap: () => ServerSelectorSheet.show(),
                ),
              ],
              const SizedBox(width: 8),
              _OverlayButton(
                icon: Icons.picture_in_picture_alt_rounded,
                onTap: () => controller.showMiniPlayer(context),
              ),
              const SizedBox(width: 8),
              _OverlayButton(
                icon: controller.isFullScreen.value
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                onTap: controller.toggleFullScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderGroup extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color accent;
  final ValueChanged<double> onChanged;

  const _SliderGroup({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VerticalSlider(
          value: value,
          icon: icon,
          accent: accent,
          onChanged: onChanged,
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Draggable vertical track with a fill and a circular thumb, matching the
/// design's brightness/volume side sliders.
class _VerticalSlider extends StatelessWidget {
  static const double _height = 130;
  static const double _width = 30;

  final double value;
  final IconData icon;
  final Color accent;
  final ValueChanged<double> onChanged;

  const _VerticalSlider({
    required this.value,
    required this.icon,
    required this.accent,
    required this.onChanged,
  });

  void _handle(Offset local) {
    final v = (1 - local.dy / _height).clamp(0.0, 1.0);
    onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _handle(d.localPosition),
      onVerticalDragStart: (d) => _handle(d.localPosition),
      onVerticalDragUpdate: (d) => _handle(d.localPosition),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 5,
                height: _height,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(color: Colors.white.withValues(alpha: 0.22)),
                    FractionallySizedBox(
                      heightFactor: clamped,
                      child: ColoredBox(color: accent),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: (_height * clamped) - 13,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF191824)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _OverlayButton({
    required this.icon,
    required this.onTap,
    this.size = 38,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
