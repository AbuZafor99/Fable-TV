import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../controllers/player_controller.dart';

/// Server picker bottom sheet from the design: signal tile, label, meta line,
/// selected radio. Switching shows the "Switching server…" overlay handled by
/// the controller.
class ServerSelectorSheet extends StatelessWidget {
  const ServerSelectorSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const ServerSelectorSheet(),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.bgSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: TColors.dividerStrong)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: TColors.bgCard3,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Choose a server',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Switch source if playback stutters',
            style: TextStyle(fontSize: 12, color: TColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: Obx(() => ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.availableStreams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final stream = controller.availableStreams[index];
                    final selected =
                        controller.currentStreamIndex.value == index;
                    return GestureDetector(
                      onTap: () {
                        controller.switchServer(index);
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: selected
                              ? TColors.primary.withValues(alpha: 0.1)
                              : TColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                selected ? TColors.primary : TColors.divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: TColors.bgElevated,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(Icons.network_check_rounded,
                                  size: 20, color: TColors.online),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stream.label?.isNotEmpty == true
                                        ? stream.label!
                                        : 'Server ${index + 1}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: TColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    stream.quality != null
                                        ? 'up to ${stream.quality}'
                                        : Uri.tryParse(stream.url)?.host ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: TColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 13),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? TColors.primary
                                      : TColors.dividerStrong,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Center(
                                      child: SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: TColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
