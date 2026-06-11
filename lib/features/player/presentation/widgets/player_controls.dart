import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/app_gradient.dart';
import '../../../../Theme/constants/app_colors.dart';
import '../controllers/player_controller.dart';
import 'server_selector_sheet.dart';

/// Custom controls overlay: gradient scrim, top bar (back / title / lock),
/// big play-pause, bottom LIVE bar with action buttons, and invisible edge
/// swipe zones for brightness (left) and volume (right).
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
              // Edge swipe zones stay active even with controls hidden.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (d) => controller.setBrightness(
                    controller.brightness.value - d.delta.dy / 300,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (d) => controller.setVolume(
                    controller.volume.value - d.delta.dy / 300,
                  ),
                ),
              ),
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
                _centerControls(controller),
                _bottomBar(controller, context),
              ],
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
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          _OverlayButton(
            icon: Icons.keyboard_arrow_down_rounded,
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
            child: Text(
              controller.channel.value?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _OverlayButton(
            icon: Icons.lock_open_rounded,
            onTap: controller.toggleLock,
          ),
          const SizedBox(width: 8),
          _OverlayButton(
            icon: controller.isFullScreen.value
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            onTap: controller.toggleFullScreen,
          ),
          const SizedBox(width: 8),
          _OverlayButton(
            icon: Icons.picture_in_picture_alt_rounded,
            onTap: () => controller.showMiniPlayer(context),
          ),
        ],
      ),
    );
  }

  Widget _centerControls(PlayerController controller) {
    return Center(
      child: GestureDetector(
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
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (controller.availableStreams.length > 1)
                _OverlayButton(
                  icon: Icons.dns_rounded,
                  onTap: () => ServerSelectorSheet.show(),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 18,
              ),
              Expanded(
                child: Slider(
                  value: controller.volume.value.clamp(0.0, 1.0),
                  activeColor: TColors.primary,
                  inactiveColor: Colors.white24,
                  onChanged: (v) {
                    controller.setVolume(v);
                    controller.startHideControlsTimer();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.brightness_6_rounded,
                color: Colors.white,
                size: 18,
              ),
              Expanded(
                child: Slider(
                  value: controller.brightness.value.clamp(0.0, 1.0),
                  activeColor: TColors.accent,
                  inactiveColor: Colors.white24,
                  onChanged: (v) {
                    controller.setBrightness(v);
                    controller.startHideControlsTimer();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
