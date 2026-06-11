import 'package:flutter/material.dart';

import '../../../../Theme/app_gradient.dart';
import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/channel_card.dart';
import '../../../../common/widgets/channel_logo.dart';
import '../../data/models/channel_model.dart';

/// "Continue watching" carousel: 168×100 hue-tinted cards with LIVE badge,
/// logo and an accent progress strip, per the design.
class RecentChannelsRow extends StatelessWidget {
  final List<ChannelModel> channels;
  final void Function(ChannelModel) onOpen;

  const RecentChannelsRow({
    super.key,
    required this.channels,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 100 thumb + 9 gap + two text lines (~19 + 2 + 17) with a little slack.
      height: 152,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _RecentCard(
          channel: channels[i],
          onTap: () => onOpen(channels[i]),
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback onTap;

  const _RecentCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = hueForId(channel.id);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 168,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 168,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppGradient.channelTint(hue),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned(top: 8, left: 8, child: LiveBadge(small: true)),
                  if (channel.quality != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: QualityBadge(channel.quality!),
                    ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: ChannelLogo(channel: channel, size: 30, radius: 9),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 3,
                      color: Colors.white.withValues(alpha: 0.14),
                      alignment: Alignment.centerLeft,
                      child: const FractionallySizedBox(
                        widthFactor: 0.7,
                        child: ColoredBox(color: TColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${channel.countryFlag} ${channel.countryName.isNotEmpty ? channel.countryName : channel.country}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
