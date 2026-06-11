import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/bottom_nav_controller.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<BottomNavController>();
    return Scaffold(
      backgroundColor: TColors.bgDark,
      extendBody: true,
      body: Obx(() => IndexedStack(
            index: navController.currentIndex.value,
            children: const [
              HomeScreen(),
              SearchScreen(),
              FavoritesScreen(),
              SettingsScreen(),
            ],
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [TColors.bgDark, Colors.transparent],
                stops: [0.6, 1.0],
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: navController.currentIndex.value,
              onTap: navController.changePage,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: TColors.primary,
              unselectedItemColor: TColors.textDisabled,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              selectedFontSize: 10.5,
              unselectedFontSize: 10.5,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.public_rounded), label: 'Discover'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded), label: 'Settings'),
              ],
            ),
          )),
    );
  }
}
