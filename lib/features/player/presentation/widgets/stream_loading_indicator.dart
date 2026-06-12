import 'package:flutter/material.dart';

import '../../../../Theme/constants/app_colors.dart';

/// Animated "radar pulse" shown over the video surface while a stream URL
/// is being resolved or the player is buffering, so the user knows the app
/// is actively working rather than frozen.
class StreamLoadingIndicator extends StatefulWidget {
  final String label;

  const StreamLoadingIndicator({super.key, this.label = 'Loading stream…'});

  @override
  State<StreamLoadingIndicator> createState() => _StreamLoadingIndicatorState();
}

class _StreamLoadingIndicatorState extends State<StreamLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _PulseRing(progress: _controller.value),
                      _PulseRing(progress: (_controller.value + 0.5) % 1.0),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [TColors.primary, TColors.primaryDark],
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;

  const _PulseRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scale = 0.35 + progress * 1.0;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: TColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
