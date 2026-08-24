import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../financial/domain/entities/partner_info.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthUnauthenticated extends AuthState {}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.partner);
  final PartnerInfo partner;
  @override
  List<Object?> get props => [partner];
}

final class AuthAccessDenied extends AuthState {}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

/// Handles login, session restore, and financial partner gate.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth, this._financial) : super(AuthInitial());

  final AuthRepository _auth;
  final FinancialRepository _financial;
  final _log = Logger();

  Future<void> checkSession() async {
    _log.i('App flow: auth checkSession START (state=${state.runtimeType})');
    emit(AuthLoading());
    final hasSession = await _auth.hasSession();
    _log.i('App flow: auth hasSession=$hasSession');
    if (!hasSession) {
      emit(AuthUnauthenticated());
      _log.i('App flow: auth → AuthUnauthenticated');
      return;
    }
    await _loadPartner(clearStaleSession: true);
  }

  Future<void> login(String email, String password) async {
    _log.i('App flow: auth login START email=$email');
    emit(AuthLoading());
    final result = await _auth.login(email: email, password: password);
    await result.fold(
      (f) async {
        final msg = _msg(f);
        _log.w('App flow: auth login FAILED type=${f.runtimeType} msg=$msg');
        emit(AuthError(msg));
      },
      (_) async {
        _log.i('App flow: auth login OK → loading partner');
        await _loadPartner();
      },
    );
  }

  Future<void> _loadPartner({bool clearStaleSession = false}) async {
    _log.i('App flow: auth loadPartner START clearStale=$clearStaleSession');
    final result = await _financial.getPartnerInfo();
    await result.fold(
      (f) async {
        _log.w(
          'App flow: auth partner FAILED type=${f.runtimeType} '
          'msg=${f.message}',
        );
        if (clearStaleSession && _shouldClearSession(f)) {
          await _auth.logout();
          emit(AuthUnauthenticated());
          _log.i('App flow: auth → AuthUnauthenticated (stale cleared)');
        } else {
          emit(AuthError(_msg(f)));
          _log.i('App flow: auth → AuthError');
        }
      },
      (p) async {
        _log.i(
          'App flow: auth partner OK isFinancial=${p.isFinancialPartner} '
          'name=${p.partnerName} id=${p.partnerId}',
        );
        if (!p.isFinancialPartner) {
          emit(AuthAccessDenied());
          _log.i('App flow: auth → AuthAccessDenied');
        } else {
          await _auth.syncPushTopics();
          emit(AuthAuthenticated(p));
          _log.i('App flow: auth → AuthAuthenticated');
        }
      },
    );
  }

  bool _shouldClearSession(Failure f) {
    if (f is AuthFailure) return true;
    if (f is ServerFailure) {
      final m = f.message.toLowerCase();
      return m.contains('access denied') ||
          m.contains('session') ||
          m.contains('authenticate');
    }
    return false;
  }

  Future<void> logout() async {
    _log.i('App flow: auth logout');
    await _auth.logout();
    emit(AuthUnauthenticated());
  }

  String _msg(Failure f) {
    if (f is AuthFailure) {
      return 'Invalid email or password. Please try again.';
    }
    if (f is NetworkFailure) {
      return 'No connection to the server. Check your internet.';
    }
    return f.message;
  }
}
