import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Theme/constants/app_colors.dart';
import '../../features/home/data/models/channel_model.dart';
import 'channel_row.dart';

/// Generic channel-list bottom sheet for the home screen's "Featured" cards
/// (FIFA World Cup, Cricket, World Cup Fixtures): icon tile + title + count
/// header and a scrollable [ChannelRowTile] list, mirroring `CountryChannelsSheet`.
class FeaturedChannelsSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ChannelModel> channels;
  final void Function(ChannelModel) onOpen;

  const FeaturedChannelsSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.channels,
    required this.onOpen,
  });

  static Future<void> show({
    required String title,
    required IconData icon,
    required List<ChannelModel> channels,
    required void Function(ChannelModel) onOpen,
  }) {
    return Get.bottomSheet(
      FeaturedChannelsSheet(
        title: title,
        icon: icon,
        channels: channels,
        onOpen: onOpen,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.bgSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: TColors.dividerStrong)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
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
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColors.bgElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TColors.divider),
                ),
                child: Icon(icon, size: 22, color: TColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${channels.length} live channels',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: TColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.divider),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 19, color: TColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: channels.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No channels found',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: channels.length,
                    itemBuilder: (_, i) {
                      final channel = channels[i];
                      return ChannelRowTile(
                        channel: channel,
                        onTap: () {
                          Get.back();
                          onOpen(channel);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
