import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

final class AccessDeniedFailure extends Failure {
  const AccessDeniedFailure([super.message = 'Access denied']);
}
