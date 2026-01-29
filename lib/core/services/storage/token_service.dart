import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/provider/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return TokenService(prefs);
});

class TokenService {
  final SharedPreferences _prefs;
  static const _key = 'auth_token';

  TokenService(this._prefs);

  Future<void> saveToken(String token) async => _prefs.setString(_key, token);
  String? getToken() => _prefs.getString(_key);
  Future<void> removeToken() async => _prefs.remove(_key);
}
