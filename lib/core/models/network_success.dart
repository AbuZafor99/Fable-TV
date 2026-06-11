import 'package:equatable/equatable.dart';

class NetworkSuccess<T> extends Equatable {
  final T data;
  final int? statusCode;

  const NetworkSuccess({required this.data, this.statusCode});

  @override
  List<Object?> get props => [data, statusCode];
}
