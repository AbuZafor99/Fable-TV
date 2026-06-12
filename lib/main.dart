import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Theme/app_theme.dart';
import 'core/init/app_initializer.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

void main() async {
  await AppInitializer.init();
  runApp(const StreamWorldApp());
}

class StreamWorldApp extends StatelessWidget {
  const StreamWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fable TV',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}
