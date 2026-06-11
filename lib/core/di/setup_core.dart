import 'package:get/get.dart';

import '../network/api_client.dart';

Future<void> setupCore() async {
  // ApiClient has its own singleton factory constructor
  Get.put<ApiClient>(ApiClient(), permanent: true);
}
