import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, Unit>> resetPassword({required String email});
  Future<void> logout();
  Future<bool> hasSession();
  Future<String?> getStoredLogin();
  Future<void> syncPushTopics();
}
