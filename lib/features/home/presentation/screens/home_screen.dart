import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/app_gradient.dart';
import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/category_chip.dart';
import '../../../../common/widgets/section_header.dart';
import '../../../../widgets/skeleton_loader.dart';
import '../../../navigation/presentation/controllers/bottom_nav_controller.dart';
import '../../../player/presentation/screens/player_screen.dart';
import '../../data/models/channel_model.dart';
import '../controllers/home_controller.dart';
import '../widgets/category_channels_section.dart';
import '../widgets/recent_channels_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openChannel(ChannelModel channel) {
    controller.addToRecent(channel);
    Get.to(() => PlayerScreen(channel: channel));
  }

  void _scrollToCategory(String categoryId) {
    final key = _sectionKeys[categoryId];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(greeting: controller.greeting),
            Expanded(
              child: Obx(() {
                final visibleCategories = controller.categories
                    .where((c) =>
                        (controller.channelsByCategory[c.id] ?? []).length >= 3)
                    .toList();
                return RefreshIndicator(
                  color: TColors.primary,
                  backgroundColor: TColors.bgCard,
                  onRefresh: controller.refreshAll,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.recentChannels.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const SectionHeader(
                            title: 'Continue watching',
                            subtitle: 'Your last 10 channels',
                          ),
                          const SizedBox(height: 13),
                          RecentChannelsRow(
                            channels: controller.recentChannels,
                            onOpen: _openChannel,
                          ),
                        ],
                        const SizedBox(height: 22),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              for (final c in visibleCategories) ...[
                                CategoryChip(
                                  label: c.name,
                                  dotColor: HSLColor.fromAHSL(
                                          1, hueForId(c.id).toDouble(), 0.5, 0.6)
                                      .toColor(),
                                  onTap: () => _scrollToCategory(c.id),
                                ),
                                const SizedBox(width: 9),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (controller.isLoadingChannels.value)
                          const SkeletonLoader(count: 3)
                        else
                          for (final c in visibleCategories) ...[
                            KeyedSubtree(
                              key: _sectionKeys.putIfAbsent(
                                  c.id, () => GlobalKey()),
                              child: CategoryChannelsSection(
                                title: c.name,
                                channels:
                                    controller.channelsByCategory[c.id] ?? [],
                                onOpen: _openChannel,
                                onSeeAll: () {
                                  Get.find<BottomNavController>()
                                      .openDiscoverWithCategory(c.id);
                                },
                              ),
                            ),
                            const SizedBox(height: 26),
                          ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String greeting;

  const _TopBar({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 21,
                          color: TColors.textPrimary,
                        ),
                    children: const [
                      TextSpan(text: 'Stream'),
                      TextSpan(
                        text: 'World',
                        style: TextStyle(color: TColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _IconButton(
            icon: Icons.search_rounded,
            onTap: () => Get.find<BottomNavController>().changePage(1),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradient.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TColors.bgCard,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: TColors.divider),
        ),
        child: Icon(icon, color: TColors.textPrimary, size: 20),
      ),
    );
  }
}
