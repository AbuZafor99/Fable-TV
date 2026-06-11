import 'package:get/get.dart';

import '../services/channel_cache_service.dart';
import '../services/connectivity_service.dart';

Future<void> setupServices() async {
  Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
  Get.put<ChannelCacheService>(ChannelCacheService(), permanent: true);
}
