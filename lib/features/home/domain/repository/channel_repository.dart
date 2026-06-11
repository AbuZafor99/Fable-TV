import '../../../../core/network/network_result.dart';
import '../../data/models/category_model.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/country_model.dart';

abstract class ChannelRepository {
  Future<NetworkResult<List<ChannelModel>>> fetchAllChannels();

  Future<NetworkResult<List<CategoryModel>>> fetchCategories();

  Future<NetworkResult<List<CountryModel>>> fetchCountries();
}
