import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/channel_card.dart';
import '../../../../common/widgets/channel_logo.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/server_selector_sheet.dart';

class PlayerScreen extends StatefulWidget {
  final ChannelModel channel;

  /// True when restored from the mini player: keep the current playback
  /// session instead of re-initializing.
  final bool resume;

  const PlayerScreen({super.key, required this.channel, this.resume = false});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PlayerController>()
        ? Get.find<PlayerController>()
        : Get.put(PlayerController(), permanent: true);
    if (!widget.resume) {
      controller.init(widget.channel);
    }
  }

  @override
  void dispose() {
    if (!controller.isMiniPlayer.value) {
      controller.stopAndRelease();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.bgDark,
      body: Obx(() {
        final video = _VideoSurface(controller: controller);
        if (controller.isFullScreen.value) {
          return SizedBox.expand(child: video);
        }
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cap the video height so the column can't overflow while the
              // device is rotating (or iOS briefly refuses to rotate back).
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: AspectRatio(aspectRatio: 16 / 10, child: video),
              ),
              if (controller.availableStreams.length > 1)
                _ServerChips(controller: controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChannelHeader(channel: controller.channel.value),
                      _ActionRow(controller: controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  final PlayerController controller;

  const _VideoSurface({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.allServersFailed.value) {
        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: TColors.live, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'No working stream found',
                  style: TextStyle(
                    color: TColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All servers for this channel are unavailable right now',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: TColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 140,
                  child:
                      context.primaryButton('Retry', onTap: controller.retry),
                ),
              ],
            ),
          ),
        );
      }

      final player = controller.betterPlayerController;
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (player != null) BetterPlayer(controller: player),
            if (controller.isBuffering.value)
              const Center(
                child: CircularProgressIndicator(color: TColors.primary),
              ),
          ],
        ),
      );
    });
  }
}

class _ServerChips extends StatelessWidget {
  final PlayerController controller;

  const _ServerChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(() => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: controller.availableStreams.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final selected = controller.currentStreamIndex.value == index;
              return GestureDetector(
                onTap: () => controller.switchServer(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? TColors.primary.withValues(alpha: 0.16)
                        : TColors.bgCard,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected
                          ? TColors.primary.withValues(alpha: 0.4)
                          : TColors.divider,
                    ),
                  ),
                  child: Text(
                    'Server ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? Colors.white : TColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

class _ChannelHeader extends StatelessWidget {
  final ChannelModel? channel;

  const _ChannelHeader({required this.channel});

  @override
  Widget build(BuildContext context) {
    final ch = channel;
    if (ch == null) return const SizedBox.shrink();
    final category = ch.categories.isNotEmpty ? ch.categories.first : 'general';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          ChannelLogo(channel: ch, size: 56, radius: 16),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: TColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${ch.countryFlag} ${ch.countryName.isNotEmpty ? ch.countryName : ch.country}  •  $category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                  ),
                ),
                if (ch.quality != null) ...[
                  const SizedBox(height: 6),
                  QualityBadge(ch.quality!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const LiveBadge(),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final PlayerController controller;

  const _ActionRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Obx(() {
        final ch = controller.channel.value;
        if (ch == null) return const SizedBox.shrink();
        final isFavorite = homeController.favoriteChannels
            .any((c) => c.id == ch.id);
        return Row(
          children: [
            Expanded(
              flex: 16,
              child: GestureDetector(
                onTap: () => homeController.toggleFavorite(ch),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isFavorite
                        ? null
                        : const LinearGradient(
                            colors: [TColors.primary, TColors.primaryDark]),
                    color: isFavorite ? TColors.bgCard : null,
                    borderRadius: BorderRadius.circular(14),
                    border: isFavorite
                        ? Border.all(color: TColors.divider)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17,
                        color: isFavorite ? TColors.live : Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        isFavorite ? 'Favorited' : 'Add to favorites',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isFavorite ? TColors.textPrimary : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: controller.availableStreams.length > 1
                    ? ServerSelectorSheet.show
                    : null,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: TColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TColors.divider),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dns_rounded,
                          size: 16, color: TColors.textPrimary),
                      SizedBox(width: 7),
                      Text(
                        'Servers',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
