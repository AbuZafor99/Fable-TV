import 'package:get/get.dart';

import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/navigation/presentation/controllers/bottom_nav_controller.dart';

void setupControllers() {
  // Permanent app-wide controllers
  Get.put<BottomNavController>(BottomNavController(), permanent: true);
  Get.put<HomeController>(HomeController(), permanent: true);
  // SearchController and PlayerController are screen-scoped:
  // Get.put() inside each screen's initState
}
