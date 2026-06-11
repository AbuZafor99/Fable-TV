import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../common/widgets/channel_card.dart';
import '../../../../common/widgets/section_header.dart';
import '../../data/models/channel_model.dart';

class CategoryChannelsSection extends StatelessWidget {
  final String title;
  final List<ChannelModel> channels;
  final void Function(ChannelModel) onOpen;
  final VoidCallback? onSeeAll;

  const CategoryChannelsSection({
    super.key,
    required this.title,
    required this.channels,
    required this.onOpen,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: '${channels.length} live channels',
          actionLabel: 'See all',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: min(10, channels.length),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => ChannelCard(
              channel: channels[i],
              onTap: () => onOpen(channels[i]),
            ),
          ),
        ),
      ],
    );
  }
}
