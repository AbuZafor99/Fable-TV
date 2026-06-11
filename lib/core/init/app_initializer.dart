import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/key_constants.dart';
import '../di/service_locator.dart';
import '../utils/debug_print.dart';
import 'hive_initialization.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: KeyConstants.envFile);
    } catch (e) {
      dPrint('No .env loaded: $e');
    }
    await HiveInitialization.init();
    await setupServiceLocator();
  }
}
