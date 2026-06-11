import 'package:flutter/material.dart';

import '../../Theme/app_gradient.dart';
import '../../features/home/data/models/channel_model.dart';
import '../../widgets/platform_image.dart';

/// Channel logo tile: real logo when available, otherwise a hue-tinted
/// gradient monogram tile like the design prototype.
class ChannelLogo extends StatelessWidget {
  final ChannelModel channel;
  final double size;
  final double radius;

  const ChannelLogo({
    super.key,
    required this.channel,
    this.size = 52,
    this.radius = 14,
  });

  String get _monogram {
    final words =
        channel.name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'TV';
    if (words.length == 1) {
      return words.first.substring(0, words.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hue = hueForId(channel.id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradient.logoTile(hue),
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: channel.logoUrl.isEmpty
          ? Center(
              child: Text(
                _monogram,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.34,
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: PlatformImage(url: channel.logoUrl),
            ),
    );
  }
}
