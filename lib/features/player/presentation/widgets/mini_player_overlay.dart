import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../controllers/player_controller.dart';
import '../screens/player_screen.dart';

/// Draggable floating PiP card (166×~93 video + info strip) inserted into the
/// root overlay so it stays above every route.
class MiniPlayerOverlay extends StatelessWidget {
  const MiniPlayerOverlay({super.key});

  static const double _width = 166;
  static const double _videoHeight = _width * 9 / 16;

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
          onTap: () {
            controller.closeMiniPlayer();
            Get.to(() => PlayerScreen(channel: channel, resume: true));
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
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
              ],
            ),
          ),
        ),
      );
    });
  }
}
