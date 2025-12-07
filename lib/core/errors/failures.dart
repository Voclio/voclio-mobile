import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = 'Unexpected Error']);

  @override
  List<Object> get props => [message];
}

// General Server Failure
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

// Cache/Local Database Failure
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

// Network Connectivity Failure
class OfflineFailure extends Failure {
  const OfflineFailure([
    super.message = 'Please check your internet connection',
  ]);
}
