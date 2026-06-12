import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/category_chip.dart';
import '../../../../common/widgets/channel_row.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/search_controller.dart';

/// Country channel list bottom sheet from the design's `CountrySheet`:
/// flag tile + name + live count header, a category filter row, and a
/// scrollable `ChannelRow` list.
class CountryChannelsSheet extends StatefulWidget {
  final String flag;
  final void Function(ChannelModel) onOpen;

  const CountryChannelsSheet({
    super.key,
    required this.flag,
    required this.onOpen,
  });

  static Future<void> show({
    required String flag,
    required void Function(ChannelModel) onOpen,
  }) {
    return Get.bottomSheet(
      CountryChannelsSheet(flag: flag, onOpen: onOpen),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  State<CountryChannelsSheet> createState() => _CountryChannelsSheetState();
}

class _CountryChannelsSheetState extends State<CountryChannelsSheet> {
  String _categoryFilter = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchController>();
    final homeController = Get.find<HomeController>();
    return Container(
      decoration: const BoxDecoration(
        color: TColors.bgSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: TColors.dividerStrong)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColors.bgElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TColors.divider),
                ),
                child: Text(widget.flag, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.selectedCountryName.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TColors.textPrimary,
                          ),
                        )),
                    const SizedBox(height: 2),
                    Obx(() {
                      final total = controller.mapResults.length;
                      final shown = _filtered(controller.mapResults).length;
                      final label = _categoryFilter.isEmpty
                          ? '$total live channels'
                          : '$shown of $total live channels';
                      return Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.textDisabled,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: TColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.divider),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 19, color: TColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final categories = _availableCategories(controller.mapResults, homeController);
            if (categories.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      label: 'All',
                      isActive: _categoryFilter.isEmpty,
                      onTap: () => setState(() => _categoryFilter = ''),
                    ),
                    for (final cat in categories) ...[
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: cat.name,
                        isActive: _categoryFilter == cat.id.toLowerCase(),
                        onTap: () => setState(() => _categoryFilter =
                            _categoryFilter == cat.id.toLowerCase()
                                ? ''
                                : cat.id.toLowerCase()),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: Obx(() {
              final results = _filtered(controller.mapResults);
              if (results.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No channels found',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final channel = results[i];
                  return ChannelRowTile(
                    channel: channel,
                    onTap: () {
                      Get.back();
                      widget.onOpen(channel);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<ChannelModel> _filtered(List<ChannelModel> channels) {
    if (_categoryFilter.isEmpty) return channels;
    return channels
        .where((c) => c.categories
            .map((e) => e.toLowerCase())
            .contains(_categoryFilter))
        .toList();
  }

  /// Categories present among this country's channels, in the home
  /// controller's display order.
  List<CategoryModel> _availableCategories(
      List<ChannelModel> channels, HomeController homeController) {
    final presentIds =
        channels.expand((c) => c.categories.map((e) => e.toLowerCase())).toSet();
    return homeController.categories
        .where((c) => presentIds.contains(c.id.toLowerCase()))
        .toList();
  }
}
