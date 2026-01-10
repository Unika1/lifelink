import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/provider/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs);
});

class UserSessionService {
  UserSessionService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = "is_logged_in";
  static const _keyUserId = "user_id";

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  Future<void> setLoggedIn(String userId) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
  }

  Future<void> logout() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
  }
}
