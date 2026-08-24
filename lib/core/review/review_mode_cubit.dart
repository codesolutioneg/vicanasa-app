import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Global flag: App Store review / demo presentation mode.
class ReviewModeCubit extends Cubit<bool> {
  ReviewModeCubit() : super(false);

  final _log = Logger();

  void enable() {
    _log.i('App flow: ReviewMode ENABLED (demo UI + hide logout)');
    emit(true);
  }

  void disable() {
    _log.i('App flow: ReviewMode DISABLED (normal partner UI)');
    emit(false);
  }

  bool get isReviewMode => state;
}
