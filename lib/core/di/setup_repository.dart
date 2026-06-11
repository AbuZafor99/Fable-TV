import 'package:get/get.dart';

import '../../features/home/data/repositories/channel_repository_impl.dart';
import '../../features/home/domain/repository/channel_repository.dart';
import '../../features/player/data/repositories/stream_repository_impl.dart';
import '../../features/player/domain/repository/stream_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repository/search_repository.dart';

void setupRepository() {
  Get.lazyPut<ChannelRepository>(
    () => ChannelRepositoryImpl(apiClient: Get.find()),
    fenix: true,
  );
  Get.lazyPut<StreamRepository>(
    () => StreamRepositoryImpl(apiClient: Get.find()),
    fenix: true,
  );
  Get.lazyPut<SearchRepository>(
    () => SearchRepositoryImpl(
      channelCache: Get.find(),
    ),
    fenix: true,
  );
}
