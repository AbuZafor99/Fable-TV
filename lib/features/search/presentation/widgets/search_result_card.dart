import 'package:flutter/material.dart';

import '../../../../common/widgets/channel_row.dart';
import '../../../home/data/models/channel_model.dart';

class SearchResultCard extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback? onTap;

  const SearchResultCard({super.key, required this.channel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChannelRowTile(channel: channel, onTap: onTap);
  }
}
