import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/category_chip.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/search_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const FilterBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final SearchController controller = Get.find();
  final HomeController homeController = Get.find();

  late final List<String> tempCategories =
      List.of(controller.activeFilterCategories);
  late String tempCountry = controller.activeFilterCountry.value;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TColors.bgSheet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: TColors.dividerStrong)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Column(
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
              Center(
                child: Text(
                  'Filter Channels',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(color: TColors.divider, height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    const Text(
                      'By Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: homeController.categories
                              .map((c) => CategoryChip(
                                    label: c.name,
                                    isActive: tempCategories.contains(c.id),
                                    onTap: () => setState(() {
                                      tempCategories.contains(c.id)
                                          ? tempCategories.remove(c.id)
                                          : tempCategories.add(c.id);
                                    }),
                                  ))
                              .toList(),
                        )),
                    const SizedBox(height: 24),
                    const Text(
                      'By Country',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => DropdownButtonFormField<String>(
                          initialValue: tempCountry.isEmpty ? null : tempCountry,
                          dropdownColor: TColors.bgElevated,
                          hint: const Text(
                            'All countries',
                            style: TextStyle(color: TColors.textDisabled),
                          ),
                          items: homeController.countries
                              .map((c) => DropdownMenuItem(
                                    value: c.code,
                                    child: Row(
                                      children: [
                                        Text(c.flag),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            c.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => tempCountry = v ?? ''),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: context.secondaryButton('Clear All', onTap: () {
                      controller.clearFilters();
                      Get.back();
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: context.primaryButton('Apply', onTap: () {
                      controller.applyFilters(tempCategories, tempCountry);
                      Get.back();
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
