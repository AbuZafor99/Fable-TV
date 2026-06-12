import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../home/data/models/channel_model.dart';
import '../controllers/player_controller.dart';
import '../screens/player_screen.dart';

/// Draggable floating PiP card (166×~93 video + info strip) inserted into the
/// root overlay so it stays above every route.
class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay>
    with SingleTickerProviderStateMixin {
  static const double _width = 166;
  static const double _videoHeight = _width * 9 / 16;

  late final AnimationController _eqController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _eqController.dispose();
    super.dispose();
  }

  void _expand(PlayerController controller, ChannelModel channel) {
    controller.closeMiniPlayer();
    Get.to(() => PlayerScreen(channel: channel, resume: true));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final screen = MediaQuery.of(context).size;
    return Obx(() {
      final player = controller.betterPlayerController;
      final channel = controller.channel.value;
      if (!controller.isMiniPlayer.value || player == null || channel == null) {
        return const SizedBox.shrink();
      }
      return Positioned(
        right: controller.miniX.value,
        bottom: controller.miniY.value,
        child: GestureDetector(
          onPanUpdate: (d) {
            controller.miniX.value = (controller.miniX.value - d.delta.dx)
                .clamp(0.0, screen.width - _width);
            controller.miniY.value = (controller.miniY.value - d.delta.dy)
                .clamp(80.0, screen.height - 160.0);
          },
          child: Container(
            width: _width,
            decoration: BoxDecoration(
              color: const Color(0xFF111019),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TColors.dividerStrong),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 14),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: _width,
                  height: _videoHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BetterPlayer(controller: player),
                      Center(
                        child: GestureDetector(
                          onTap: controller.togglePlayPause,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              controller.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () =>
                              controller.closeMiniPlayer(stopPlayback: true),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _expand(controller, channel),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.open_in_full_rounded,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _expand(controller, channel),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        if (controller.isPlaying.value)
                          AnimatedBuilder(
                            animation: _eqController,
                            builder: (_, __) => _Equalizer(t: _eqController.value),
                          )
                        else
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: TColors.live,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            channel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: TColors.textPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// 4-bar "now playing" equalizer, matching the design's `eq` keyframes
/// (triangle wave: 30% -> 100% -> 30%, staggered per bar).
class _Equalizer extends StatelessWidget {
  final double t;

  const _Equalizer({required this.t});

  static double _barScale(double t, double phase) {
    final p = (t + phase) % 1.0;
    final v = p < 0.5 ? p / 0.5 : (1 - p) / 0.5;
    return 0.3 + 0.7 * v;
  }

  @override
  Widget build(BuildContext context) {
    const height = 10.0;
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          final scale = _barScale(t, i * 0.13 / 1.1);
          return Container(
            width: 2.5,
            height: height * scale,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
