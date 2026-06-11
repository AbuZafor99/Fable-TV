import 'package:flutter/material.dart';

import '../../Theme/app_gradient.dart';
import '../../Theme/constants/app_colors.dart';
import '../../features/home/data/models/channel_model.dart';
import 'channel_logo.dart';

/// Poster card from the design (124×150): hue-tinted backdrop, bottom scrim,
/// LIVE dot, logo, name, country code badge + resolution.
class ChannelCard extends StatelessWidget {
  final ChannelModel channel;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    this.width = 124,
    this.height = 150,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hue = hueForId(channel.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: AppGradient.channelTint(hue),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradient.cardScrim),
              ),
            ),
            const Positioned(top: 8, left: 8, child: LiveBadge(small: true)),
            if (channel.quality != null)
              Positioned(top: 8, right: 8, child: QualityBadge(channel.quality!)),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChannelLogo(channel: channel, size: 34, radius: 10),
                  const SizedBox(height: 7),
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      CodeBadge(code: channel.country),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          channel.countryFlag.isNotEmpty
                              ? channel.countryFlag
                              : (channel.categories.isNotEmpty
                                  ? channel.categories.first
                                  : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CodeBadge extends StatelessWidget {
  final String code;

  const CodeBadge({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TColors.dividerStrong, width: 0.5),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class QualityBadge extends StatelessWidget {
  final String quality;

  const QualityBadge(this.quality, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        quality,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  final bool small;

  const LiveBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: small ? Colors.black.withValues(alpha: 0.35) : TColors.live.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 8,
            height: small ? 6 : 8,
            decoration: const BoxDecoration(
              color: TColors.live,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: TColors.live, blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: small ? Colors.white : TColors.live,
              fontSize: small ? 8.5 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
