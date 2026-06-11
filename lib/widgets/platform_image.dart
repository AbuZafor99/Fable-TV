import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Theme/constants/app_colors.dart';

/// Renders a network image with caching, transparently handling SVG logos
/// (common in iptv-org data) and falling back to a TV icon on error.
class PlatformImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PlatformImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  bool get _isSvg => url.toLowerCase().split('?').first.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback();
    if (_isSvg) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _placeholder(),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: TColors.shimmerBase,
      );

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: TColors.bgElevated,
        child: Icon(
          Icons.live_tv_rounded,
          color: TColors.textSecondary,
          size: (height ?? 40) * 0.5,
        ),
      );
}
