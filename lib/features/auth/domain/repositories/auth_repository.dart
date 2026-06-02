import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<bool> hasSession();
  Future<String?> getStoredLogin();
}
