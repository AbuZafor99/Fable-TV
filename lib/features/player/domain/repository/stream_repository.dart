import '../../../../core/network/network_result.dart';
import '../../data/models/stream_model.dart';

abstract class StreamRepository {
  Future<NetworkResult<List<StreamModel>>> fetchAllStreams();
}
