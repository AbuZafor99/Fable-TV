import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/category_chip.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/data/models/country_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../player/presentation/screens/player_screen.dart';
import '../controllers/search_controller.dart';
import '../widgets/country_channels_sheet.dart';
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

  Future<void> _openCountryByPin(CountryModel country) async {
    await controller.onCountryPinTap(country);
    _showCountrySheet(country.flag);
  }

  Future<void> _openCountryByMapTap(double lat, double lng) async {
    await controller.onMapTap(lat, lng);
    final code = controller.selectedCountryCode.value;
    if (code.isEmpty) return;
    final flag = homeController.countryByCode[code]?.flag ?? '🌍';
    _showCountrySheet(flag);
  }

  void _showCountrySheet(String flag) {
    CountryChannelsSheet.show(flag: flag, onOpen: _openChannel);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => _SegmentedToggle(
                    isCategoryMode: controller.isCategoryMode.value,
                    onChanged: controller.setCategoryMode,
                  )),
            ),
            Obx(() {
              if (!controller.isCategoryMode.value) {
                return const SizedBox(height: 12);
              }
              return Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Obx(() => CategoryChip(
                              label: 'All',
                              isActive: controller.activeFilterCategories.isEmpty,
                              onTap: () => controller.selectCategory(''),
                            )),
                        const SizedBox(width: 8),
                        ...homeController.categories.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Obx(() => CategoryChip(
                                    label: c.name,
                                    isActive: controller.activeFilterCategories
                                        .contains(c.id),
                                    onTap: () => controller.selectCategory(c.id),
                                  )),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                final hasQuery = controller.query.value.trim().isNotEmpty ||
                    controller.hasActiveFilters;

                if (hasQuery) {
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
                }

                if (controller.isCategoryMode.value) {
                  return const _CategoryEmptyState();
                }

                return _MapView(
                  controller: controller,
                  homeController: homeController,
                  onCountryTap: _openCountryByPin,
                  onMapTap: _openCountryByMapTap,
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
  final void Function(CountryModel) onCountryTap;
  final void Function(double, double) onMapTap;

  const _MapView({
    required this.controller,
    required this.homeController,
    required this.onCountryTap,
    required this.onMapTap,
  });

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
              onCountryTap: onCountryTap,
              onMapTap: onMapTap,
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
                    onTap: () => onCountryTap(country),
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

/// Segmented Category/Country toggle from the design's `.seg` chip group.
class _SegmentedToggle extends StatelessWidget {
  final bool isCategoryMode;
  final ValueChanged<bool> onChanged;

  const _SegmentedToggle({required this.isCategoryMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TColors.bgCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: TColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegButton(
            label: 'Category',
            isActive: isCategoryMode,
            onTap: () => onChanged(true),
          ),
          _SegButton(
            label: 'Country',
            isActive: !isCategoryMode,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegButton(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? TColors.bgCard3 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : TColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryEmptyState extends StatelessWidget {
  const _CategoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_rounded, size: 48, color: TColors.textDisabled),
          SizedBox(height: 12),
          Text(
            'Pick a category',
            style: TextStyle(
              color: TColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Choose a category above to browse live channels',
            style: TextStyle(color: TColors.textDisabled, fontSize: 12),
          ),
        ],
      ),
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
