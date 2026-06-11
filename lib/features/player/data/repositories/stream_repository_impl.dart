import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/network_success.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_result.dart';
import '../../domain/repository/stream_repository.dart';
import '../models/stream_model.dart';

class StreamRepositoryImpl implements StreamRepository {
  final ApiClient apiClient;

  StreamRepositoryImpl({required this.apiClient});

  @override
  Future<NetworkResult<List<StreamModel>>> fetchAllStreams() async {
    final result = await apiClient.getPlain(ApiConstants.iptvOrg.streams);
    return result.fold(
      (failure) => Left(failure),
      (success) async {
        // 30k+ items: decode off the main isolate.
        final streams = await compute(parseIptvOrgStreams, success.data);
        return Right(NetworkSuccess(data: streams, statusCode: success.statusCode));
      },
    );
  }
}

// Top-level so it can run in a background isolate via compute.
List<StreamModel> parseIptvOrgStreams(String body) {
  final list = jsonDecode(body) as List;
  return list
      .map((e) => StreamModel.fromIptvOrg(e as Map<String, dynamic>))
      .where((s) => !s.isBroken && s.url.isNotEmpty && s.channelId.isNotEmpty)
      .toList();
}
