import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';

class OnboardingRepository {
  OnboardingRepository(this._prefs);
  final SharedPreferences _prefs;

  bool isCompleted() =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<void> complete() =>
      _prefs.setBool(StorageKeys.onboardingCompleted, true);
}
