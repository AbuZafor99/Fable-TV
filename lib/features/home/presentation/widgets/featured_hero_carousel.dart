import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/app_gradient.dart';
import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/channel_card.dart';
import '../../../../common/widgets/channel_logo.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../data/models/channel_model.dart';
import '../controllers/home_controller.dart';

/// Auto-sliding "spotlight" banner shown at the top of the home screen,
/// cycling through a handful of featured channels per the design.
class FeaturedHeroCarousel extends StatefulWidget {
  final List<ChannelModel> channels;
  final void Function(ChannelModel) onOpen;

  const FeaturedHeroCarousel({
    super.key,
    required this.channels,
    required this.onOpen,
  });

  @override
  State<FeaturedHeroCarousel> createState() => _FeaturedHeroCarouselState();
}

class _FeaturedHeroCarouselState extends State<FeaturedHeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _restartAutoSlide();
  }

  @override
  void didUpdateWidget(covariant FeaturedHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channels.length != widget.channels.length) {
      _page = 0;
      _restartAutoSlide();
    }
  }

  void _restartAutoSlide() {
    _timer?.cancel();
    if (widget.channels.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_pageController.hasClients) return;
      final next = (_page + 1) % widget.channels.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channels = widget.channels;
    if (channels.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 226,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: channels.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroCard(
                channel: channels[i],
                onOpen: () => widget.onOpen(channels[i]),
              ),
            ),
          ),
          if (channels.length > 1)
            Positioned(
              right: 36,
              bottom: 18,
              child: IgnorePointer(
                child: Row(
                  children: List.generate(
                    channels.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 5),
                      width: i == _page ? 16 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback onOpen;

  const _HeroCard({required this.channel, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final category = channel.categories.isNotEmpty ? channel.categories.first : '';
    final country = channel.countryName.isNotEmpty ? channel.countryName : channel.country;
    final metaParts = [
      country,
      if (category.isNotEmpty && category.toLowerCase() != 'general') _titleCase(category),
      if (channel.quality != null) channel.quality!,
    ].where((e) => e.isNotEmpty).toList();

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: ChannelBackdrop(channel: channel)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradient.cardScrim),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const LiveBadge(),
                      const SizedBox(width: 10),
                      Icon(Icons.remove_red_eye_rounded,
                          size: 13, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _watchingLabel(channel.id),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      ChannelLogo(channel: channel, size: 44, radius: 14),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NOW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _nowProgramFor(channel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (channel.country.isNotEmpty) ...[
                        CodeBadge(code: channel.country),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          metaParts.join('  •  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onOpen,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded,
                                    size: 18, color: Color(0xFF0E0E16)),
                                SizedBox(width: 6),
                                Text(
                                  'Watch live',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0E0E16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Builder(builder: (context) {
                        final home = Get.find<HomeController>();
                        return Obx(() {
                          final isFav = home.favoriteChannels.any((c) => c.id == channel.id);
                          return _CircleIconButton(
                            icon: isFav ? Icons.star_rounded : Icons.star_border_rounded,
                            active: isFav,
                            onTap: () => home.toggleFavorite(channel),
                          );
                        });
                      }),
                      const SizedBox(width: 9),
                      _CircleIconButton(
                        icon: Icons.info_outline_rounded,
                        onTap: () => _showInfoSheet(context, channel, onOpen),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _CircleIconButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, size: 19, color: active ? TColors.warning : Colors.white),
      ),
    );
  }
}

void _showInfoSheet(BuildContext context, ChannelModel channel, VoidCallback onOpen) {
  final country = channel.countryName.isNotEmpty ? channel.countryName : channel.country;
  final category =
      channel.categories.isNotEmpty ? _titleCase(channel.categories.first) : 'General';
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: TColors.bgSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: TColors.dividerStrong)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: TColors.bgCard3,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ChannelLogo(channel: channel, size: 52, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${channel.countryFlag} $country  •  $category'
                      '${channel.quality != null ? '  •  ${channel.quality}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: TColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TColors.primary.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'NOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: TColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _nowProgramFor(channel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Watch now',
            onTap: () {
              Get.back();
              onOpen();
            },
          ),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

String _titleCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Deterministic "X.XK watching" label derived from the channel id, purely
/// for visual flavor (the API doesn't expose live viewer counts).
String _watchingLabel(String channelId) {
  final hash = channelId.codeUnits.fold<int>(0, (a, c) => a + c * 31);
  final value = 1.2 + (hash % 798) / 10; // ~1.2K – 80.9K
  return '${value.toStringAsFixed(1)}K watching';
}

const _programsByCategory = <String, List<String>>{
  'movies': ['Saturday Blockbuster', 'Midnight Feature', "Director's Cut", 'Premiere Tonight'],
  'news': ['Global Headlines', 'Morning Brief', 'Breaking: Live Coverage', 'World Today'],
  'sports': ['Champions Night — Live', 'Match Day Live', 'Grand Prix Qualifying', 'World Cup Replay'],
  'kids': ['Cartoon Carnival', 'Animation Hour', 'Story Time', 'Adventure Squad'],
  'music': ['Top 40 Countdown', 'Live Acoustic Set', 'New Releases', 'Late Night Beats'],
  'documentary': ['Planet Deep Dive', 'Wild Frontiers', 'Cosmos Explained'],
  'entertainment': ['The Late Show', 'Prime Time Special', 'Studio Sessions'],
  'lifestyle': ['Kitchen Stories', 'Travel Diaries', 'Wellness Hour'],
};

const _defaultPrograms = ['Live Now', 'On Air', 'Live Broadcast'];

/// Deterministic "now playing" label derived from the channel's category and
/// id, purely for visual flavor (the API doesn't expose an EPG).
String _nowProgramFor(ChannelModel channel) {
  final category = channel.categories
      .map((c) => c.toLowerCase())
      .firstWhere(_programsByCategory.containsKey, orElse: () => '');
  final list = _programsByCategory[category] ?? _defaultPrograms;
  final hash = channel.id.codeUnits.fold<int>(0, (a, c) => a + c * 17);
  return list[hash % list.length];
}
