import 'package:flutter/material.dart';

import '../../Theme/constants/app_colors.dart';
import '../../features/home/data/models/channel_model.dart';
import 'channel_logo.dart';

/// List-style channel row from the design: 52px logo, name, meta line with
/// LIVE dot, and a play affordance.
class ChannelRowTile extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback? onTap;

  const ChannelRowTile({super.key, required this.channel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final category =
        channel.categories.isNotEmpty ? channel.categories.first : 'general';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            ChannelLogo(channel: channel, size: 52, radius: 14),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
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
                      fontSize: 12,
                      color: TColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: TColors.live,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: TColors.textDisabled,
                        ),
                      ),
                      if (channel.quality != null) ...[
                        const SizedBox(width: 7),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: TColors.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          channel.quality!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: TColors.textDisabled,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: TColors.bgElevated,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: TColors.divider),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 18, color: TColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
