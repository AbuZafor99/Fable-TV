import 'package:dartz/dartz.dart';

import '../models/network_failure.dart';
import '../models/network_success.dart';

typedef NetworkResult<T> = Either<NetworkFailure, NetworkSuccess<T>>;
