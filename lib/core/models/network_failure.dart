import 'package:equatable/equatable.dart';

class NetworkFailure extends Equatable {
  final String message;
  final int? statusCode;

  const NetworkFailure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
