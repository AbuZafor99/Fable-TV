import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../common/widgets/channel_card.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../player/presentation/screens/player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: TColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 21,
                      color: TColors.textPrimary,
                    ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final favorites = homeController.favoriteChannels;
                if (favorites.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 48, color: TColors.textDisabled),
                        SizedBox(height: 12),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Open a channel and tap "Add to favorites"',
                          style: TextStyle(
                              color: TColors.textDisabled, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 124 / 150,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (_, i) => ChannelCard(
                    channel: favorites[i],
                    onTap: () {
                      homeController.addToRecent(favorites[i]);
                      Get.to(() => PlayerScreen(channel: favorites[i]));
                    },
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
