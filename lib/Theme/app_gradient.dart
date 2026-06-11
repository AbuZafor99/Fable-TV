import 'package:flutter/material.dart';

import 'constants/app_colors.dart';

/// Top dark → transparent → bottom dark, laid over the video surface so the
/// controls stay readable.
const LinearGradient kPlayerOverlayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.black54,
    Colors.transparent,
    Colors.transparent,
    Colors.black87,
  ],
  stops: [0.0, 0.22, 0.6, 1.0],
);

class AppGradient {
  AppGradient._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TColors.primary, TColors.primaryDark],
  );

  static const LinearGradient cardScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Colors.black54, Colors.transparent],
    stops: [0.0, 0.55],
  );

  /// Per-channel tinted thumbnail backdrop, hue derived from the channel id —
  /// stands in behind logos the way the design's striped tiles do.
  static LinearGradient channelTint(int hue) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hue.toDouble(), 0.40, 0.26).toColor(),
          HSLColor.fromAHSL(1, ((hue + 30) % 360).toDouble(), 0.35, 0.13).toColor(),
        ],
      );

  static LinearGradient logoTile(int hue) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.55).toColor(),
          HSLColor.fromAHSL(1, ((hue + 40) % 360).toDouble(), 0.50, 0.38).toColor(),
        ],
      );
}

int hueForId(String id) => id.codeUnits.fold<int>(0, (a, c) => a + c * 31) % 360;
