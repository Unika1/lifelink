import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late TokenService tokenService;
  late MockSharedPreferences mockPrefs;

  const tokenKey = 'auth_token';
  const tToken = 'test_auth_token_123';

  setUp(() {
    mockPrefs = MockSharedPreferences();
    tokenService = TokenService(mockPrefs);
  });

  group('TokenService', () {
    test('saveToken stores token in shared preferences', () async {
      when(() => mockPrefs.setString(tokenKey, tToken))
          .thenAnswer((_) async => true);

      await tokenService.saveToken(tToken);

      verify(() => mockPrefs.setString(tokenKey, tToken)).called(1);
    });

    test('getToken returns token when present', () {
      when(() => mockPrefs.getString(tokenKey)).thenReturn(tToken);

      final result = tokenService.getToken();

      expect(result, tToken);
      verify(() => mockPrefs.getString(tokenKey)).called(1);
    });

    test('getToken returns null when token is not present', () {
      when(() => mockPrefs.getString(tokenKey)).thenReturn(null);

      final result = tokenService.getToken();

      expect(result, isNull);
      verify(() => mockPrefs.getString(tokenKey)).called(1);
    });

    test('removeToken removes token from shared preferences', () async {
      when(() => mockPrefs.remove(tokenKey)).thenAnswer((_) async => true);

      await tokenService.removeToken();

      verify(() => mockPrefs.remove(tokenKey)).called(1);
    });
  });
}