import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../home/data/models/country_model.dart';

/// Stylized dotted world map from the design handoff: the bundled SVG with
/// glowing, pulsing country pins positioned by lng/lat. The SVG spans
/// lat +80..-58, lng -180..180 (1000×383 viewBox).
class WorldMapWidget extends StatefulWidget {
  final List<CountryModel> countries;
  final Map<String, int> channelCounts;
  final String activeCountryCode;
  final void Function(CountryModel) onCountryTap;
  final void Function(double lat, double lng)? onMapTap;

  const WorldMapWidget({
    super.key,
    required this.countries,
    required this.channelCounts,
    this.activeCountryCode = '',
    required this.onCountryTap,
    this.onMapTap,
  });

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget>
    with SingleTickerProviderStateMixin {
  static const double _latTop = 80;
  static const double _latSpan = 138;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Offset _project(CountryModel c, Size size) => Offset(
        (c.longitude + 180) / 360 * size.width,
        (_latTop - c.latitude) / _latSpan * size.height,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.divider),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0E18), Color(0xFF0A0A11)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxWidth * 0.383);
          final pinned = widget.countries
              .where((c) =>
                  c.hasCoordinates && (widget.channelCounts[c.code] ?? 0) > 0)
              .toList();
          return SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTapUp: (details) {
                    final local = details.localPosition;
                    final lng = local.dx / size.width * 360 - 180;
                    final lat = _latTop - local.dy / size.height * _latSpan;
                    widget.onMapTap?.call(lat, lng);
                  },
                  child: SvgPicture.asset(
                    'assets/images/world_dots.svg',
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.fill,
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.1),
                        radius: 0.9,
                        colors: [Color(0x1F7C5CFF), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                for (final country in pinned)
                  _buildPin(country, _project(country, size)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPin(CountryModel country, Offset position) {
    final count = widget.channelCounts[country.code] ?? 0;
    final big = count >= 100;
    final active = widget.activeCountryCode == country.code;
    final coreSize = big ? 9.0 : 7.0;
    final haloSize = big ? 26.0 : 20.0;
    return Positioned(
      left: position.dx - haloSize / 2,
      top: position.dy - haloSize / 2,
      width: haloSize,
      height: haloSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onCountryTap(country),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) {
                final t = Curves.easeInOut
                    .transform((_pulse.value * 2) % 1.0);
                return Opacity(
                  opacity: 0.7 - 0.35 * t,
                  child: Transform.scale(
                    scale: 0.85 + 0.3 * t,
                    child: Container(
                      width: haloSize,
                      height: haloSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x8C7C5CFF), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              width: coreSize,
              height: coreSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : TColors.primaryLight,
                boxShadow: [
                  BoxShadow(
                    color: active ? Colors.white : TColors.primary,
                    blurRadius: active ? 14 : 10,
                    spreadRadius: 2,
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
