import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/env.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/odoo_client.dart';
import '../../../../core/notifications/firebase_messaging_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._client,
    this._secure,
    this._prefs,
  );

  final OdooClient _client;
  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.authenticate(
        db: Env.odooDb,
        login: email.trim(),
        password: password,
      );
      // Remember login email only — Odoo session lives in HTTP cookies (persisted on mobile).
      await _secure.write(key: StorageKeys.sessionLogin, value: email.trim());
      await _prefs.setString(StorageKeys.sessionDb, Env.odooDb);
      await FirebaseMessagingService.instance.subscribeUserTopics(email);
      return const Right(unit);
    } on NetworkException {
      return Left(NetworkFailure(_networkMessage()));
    } on AuthException {
      return const Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> syncPushTopics() async {
    final email = await getStoredLogin();
    if (email != null && email.isNotEmpty) {
      await FirebaseMessagingService.instance.subscribeUserTopics(email);
    }
  }

  @override
  Future<void> logout() async {
    await FirebaseMessagingService.instance.unsubscribeUserTopics();
    await _client.logout();
    await _secure.delete(key: StorageKeys.sessionLogin);
  }

  @override
  Future<bool> hasSession() async {
    final login = await _secure.read(key: StorageKeys.sessionLogin);
    return login != null && login.isNotEmpty;
  }

  @override
  Future<String?> getStoredLogin() =>
      _secure.read(key: StorageKeys.sessionLogin);

  String _networkMessage() {
    if (kIsWeb) {
      return 'Cannot reach Odoo from the browser (CORS/network). '
          'Upgrade partner_financial_portal on the server (≥18.0.1.4.0), '
          'or run the app on Windows/Android instead of Chrome.';
    }
    return 'No connection to the server. Check your internet.';
  }
}
