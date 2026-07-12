import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> checkSession() async {
    emit(AuthLoading());
    if (!await _auth.hasSession()) {
      emit(AuthUnauthenticated());
      return;
    }
    await _loadPartner(clearStaleSession: true);
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _auth.login(email: email, password: password);
    await result.fold(
      (f) async => emit(AuthError(_msg(f))),
      (_) async => _loadPartner(),
    );
  }

  Future<void> _loadPartner({bool clearStaleSession = false}) async {
    final result = await _financial.getPartnerInfo();
    await result.fold(
      (f) async {
        if (clearStaleSession && _shouldClearSession(f)) {
          await _auth.logout();
          emit(AuthUnauthenticated());
        } else {
          emit(AuthError(_msg(f)));
        }
      },
      (p) async {
        if (!p.isFinancialPartner) {
          emit(AuthAccessDenied());
        } else {
          await _auth.syncPushTopics();
          emit(AuthAuthenticated(p));
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
