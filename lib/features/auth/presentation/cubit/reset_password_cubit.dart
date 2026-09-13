import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();
  @override
  List<Object?> get props => [];
}

final class ResetPasswordInitial extends ResetPasswordState {}

final class ResetPasswordLoading extends ResetPasswordState {}

final class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess(this.email);
  final String email;
  @override
  List<Object?> get props => [email];
}

final class ResetPasswordError extends ResetPasswordState {
  const ResetPasswordError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._auth) : super(ResetPasswordInitial());

  final AuthRepository _auth;
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> submit(String rawEmail) async {
    final email = rawEmail.trim();
    if (email.isEmpty || !_emailRe.hasMatch(email)) {
      emit(const ResetPasswordError('Please enter a valid email address.'));
      return;
    }
    emit(ResetPasswordLoading());
    final result = await _auth.resetPassword(email: email);
    result.fold(
      (f) => emit(ResetPasswordError(_msg(f))),
      (_) => emit(ResetPasswordSuccess(email)),
    );
  }

  String _msg(Failure f) {
    if (f is NetworkFailure) {
      return 'No connection to the server. Check your internet.';
    }
    return f.message;
  }
}
