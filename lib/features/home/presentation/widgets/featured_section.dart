import 'package:flutter/material.dart';

import '../../../../common/widgets/featured_channels_sheet.dart';
import '../../data/models/channel_model.dart';

/// "Featured" row below Continue watching: FIFA World Cup, Cricket and World
/// Cup Fixtures cards. Tapping a card opens a [FeaturedChannelsSheet] listing
/// its channels, same flow as the country channel sheet on Discover.
class FeaturedSection extends StatelessWidget {
  final List<ChannelModel> fifaChannels;
  final List<ChannelModel> cricketChannels;
  final List<ChannelModel> fixturesChannels;
  final void Function(ChannelModel) onOpen;

  const FeaturedSection({
    super.key,
    required this.fifaChannels,
    required this.cricketChannels,
    required this.fixturesChannels,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FeaturedCard(
            title: 'FIFA World Cup',
            subtitle: '${fifaChannels.length} live channels',
            icon: Icons.sports_soccer_rounded,
            colors: const [Color(0xFF22A06B), Color(0xFF0B5C36)],
            onTap: () => FeaturedChannelsSheet.show(
              title: 'FIFA World Cup',
              icon: Icons.sports_soccer_rounded,
              channels: fifaChannels,
              onOpen: onOpen,
            ),
          ),
          const SizedBox(width: 14),
          _FeaturedCard(
            title: 'Cricket',
            subtitle: '${cricketChannels.length} live channels',
            icon: Icons.sports_cricket_rounded,
            colors: const [Color(0xFFE2862F), Color(0xFF8C4513)],
            onTap: () => FeaturedChannelsSheet.show(
              title: 'Cricket',
              icon: Icons.sports_cricket_rounded,
              channels: cricketChannels,
              onOpen: onOpen,
            ),
          ),
          const SizedBox(width: 14),
          _FeaturedCard(
            title: 'World Cup Fixtures',
            subtitle: '${fixturesChannels.length} live channels',
            icon: Icons.emoji_events_rounded,
            colors: const [Color(0xFF7C5CFF), Color(0xFF3E2A99)],
            onTap: () => FeaturedChannelsSheet.show(
              title: 'World Cup Fixtures',
              icon: Icons.emoji_events_rounded,
              channels: fixturesChannels,
              onOpen: onOpen,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        height: 112,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
