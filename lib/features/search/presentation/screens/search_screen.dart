import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/channel_card.dart';
import '../../../../common/widgets/section_header.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../player/presentation/screens/player_screen.dart';
import '../controllers/search_controller.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_result_card.dart';
import '../widgets/world_map_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  late final SearchController controller;
  late final HomeController homeController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    controller = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController(), permanent: true);
  }

  void _openChannel(ChannelModel channel) {
    homeController.addToRecent(channel);
    Get.to(() => PlayerScreen(channel: channel));
  }

  /// Pre-applies a category filter; used by Home's "See all".
  void applyCategory(String categoryId) {
    controller.applyFilters([categoryId], '');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: TColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Discover',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 21,
                        color: TColors.textPrimary,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchTf,
                      onChanged: controller.onQueryChanged,
                      style: const TextStyle(
                          color: TColors.textPrimary, fontSize: 14.5),
                      decoration: InputDecoration(
                        hintText: 'Search channels, countries...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: TColors.textDisabled),
                        suffixIcon: Obx(() => controller.query.value.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: TColors.textSecondary),
                                onPressed: () {
                                  controller.searchTf.clear();
                                  controller.onQueryChanged('');
                                },
                              )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => _FilterButton(
                        hasActiveFilters: controller.hasActiveFilters,
                        onTap: FilterBottomSheet.show,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final hasQuery = controller.query.value.trim().isNotEmpty ||
                    controller.hasActiveFilters;

                if (!hasQuery && !controller.showMapResults.value) {
                  return _MapView(
                    controller: controller,
                    homeController: homeController,
                  );
                }

                if (!hasQuery && controller.showMapResults.value) {
                  return _MapResults(
                    controller: controller,
                    onOpen: _openChannel,
                  );
                }

                if (controller.searchResults.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
                  itemCount: controller.searchResults.length,
                  itemBuilder: (_, i) => SearchResultCard(
                    channel: controller.searchResults[i],
                    onTap: () => _openChannel(controller.searchResults[i]),
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

class _MapView extends StatelessWidget {
  final SearchController controller;
  final HomeController homeController;

  const _MapView({required this.controller, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        const Text(
          'Tap a glowing pin to explore a country\'s live channels',
          style: TextStyle(fontSize: 11.5, color: TColors.textDisabled),
        ),
        const SizedBox(height: 12),
        Obx(() => WorldMapWidget(
              countries: homeController.countries,
              channelCounts: homeController.channelCountByCountry,
              activeCountryCode: controller.selectedCountryCode.value,
              onCountryTap: controller.onCountryPinTap,
              onMapTap: controller.onMapTap,
            )),
        const SizedBox(height: 24),
        Obx(() {
          final popular = homeController.countries
              .where((c) =>
                  (homeController.channelCountByCountry[c.code] ?? 0) > 0)
              .toList()
            ..sort((a, b) =>
                (homeController.channelCountByCountry[b.code] ?? 0).compareTo(
                    homeController.channelCountByCountry[a.code] ?? 0));
          final top = popular.take(8).toList();
          if (top.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Popular regions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        color: TColors.textPrimary,
                      ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 11,
                  childAspectRatio: 2.1,
                ),
                itemCount: top.length,
                itemBuilder: (_, i) {
                  final country = top[i];
                  final count =
                      homeController.channelCountByCountry[country.code] ?? 0;
                  return GestureDetector(
                    onTap: () => controller.onCountryPinTap(country),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: TColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${country.flag} ${country.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count live channels',
                            style: const TextStyle(
                              fontSize: 11,
                              color: TColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _MapResults extends StatelessWidget {
  final SearchController controller;
  final void Function(ChannelModel) onOpen;

  const _MapResults({required this.controller, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
          child: SectionHeader(
            title: controller.selectedCountryName.value,
            subtitle: '${controller.mapResults.length} live channels',
            actionLabel: 'Back to map',
            onAction: controller.clearMapSelection,
          ),
        ),
        Expanded(
          child: controller.mapResults.isEmpty
              ? const _EmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 124 / 150,
                  ),
                  itemCount: controller.mapResults.length,
                  itemBuilder: (_, i) {
                    final channel = controller.mapResults[i];
                    return ChannelCard(
                      channel: channel,
                      onTap: () => onOpen(channel),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore_rounded,
              size: 48, color: TColors.textDisabled),
          SizedBox(height: 12),
          Text(
            'No channels found',
            style: TextStyle(
              color: TColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different search or filter',
            style: TextStyle(color: TColors.textDisabled, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onTap;

  const _FilterButton({required this.hasActiveFilters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? TColors.primary.withValues(alpha: 0.16)
              : TColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasActiveFilters
                ? TColors.primary.withValues(alpha: 0.4)
                : TColors.dividerStrong,
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: hasActiveFilters ? TColors.primary : TColors.textPrimary,
        ),
      ),
    );
  }
}
