import 'package:get/get.dart';

import '../../../search/presentation/controllers/search_controller.dart';

class BottomNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Home's "See all" jumps to Discover with that category pre-filtered.
  void openDiscoverWithCategory(String categoryId) {
    changePage(1);
    if (Get.isRegistered<SearchController>()) {
      Get.find<SearchController>().applyFilters([categoryId], '');
    }
  }
}
