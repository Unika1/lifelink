import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late UserSessionService userSessionService;
  late MockSharedPreferences mockPrefs;

  const keyIsLoggedIn = 'is_logged_in';
  const keyUserId = 'user_id';
  const keyUserRole = 'user_role';

  const tUserId = 'user_123';
  const tRole = 'hospital';

  setUp(() {
    mockPrefs = MockSharedPreferences();
    userSessionService = UserSessionService(mockPrefs);
  });

  group('UserSessionService', () {
    test('setLoggedIn saves login status, user id and role', () async {
      when(() => mockPrefs.setBool(keyIsLoggedIn, true))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.setString(keyUserId, tUserId))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.setString(keyUserRole, tRole))
          .thenAnswer((_) async => true);

      await userSessionService.setLoggedIn(tUserId, role: tRole);

      verify(() => mockPrefs.setBool(keyIsLoggedIn, true)).called(1);
      verify(() => mockPrefs.setString(keyUserId, tUserId)).called(1);
      verify(() => mockPrefs.setString(keyUserRole, tRole)).called(1);
    });

    test('isLoggedIn returns true when flag is set', () {
      when(() => mockPrefs.getBool(keyIsLoggedIn)).thenReturn(true);

      final result = userSessionService.isLoggedIn();

      expect(result, true);
      verify(() => mockPrefs.getBool(keyIsLoggedIn)).called(1);
    });

    test('isLoggedIn returns false when flag is missing', () {
      when(() => mockPrefs.getBool(keyIsLoggedIn)).thenReturn(null);

      final result = userSessionService.isLoggedIn();

      expect(result, false);
      verify(() => mockPrefs.getBool(keyIsLoggedIn)).called(1);
    });

    test('getUserId returns stored user id', () {
      when(() => mockPrefs.getString(keyUserId)).thenReturn(tUserId);

      final result = userSessionService.getUserId();

      expect(result, tUserId);
      verify(() => mockPrefs.getString(keyUserId)).called(1);
    });

    test('getUserRole returns donor when role is missing', () {
      when(() => mockPrefs.getString(keyUserRole)).thenReturn(null);

      final result = userSessionService.getUserRole();

      expect(result, 'donor');
      verify(() => mockPrefs.getString(keyUserRole)).called(1);
    });

    test('logout removes all session keys', () async {
      when(() => mockPrefs.remove(keyIsLoggedIn)).thenAnswer((_) async => true);
      when(() => mockPrefs.remove(keyUserId)).thenAnswer((_) async => true);
      when(() => mockPrefs.remove(keyUserRole)).thenAnswer((_) async => true);

      await userSessionService.logout();

      verify(() => mockPrefs.remove(keyIsLoggedIn)).called(1);
      verify(() => mockPrefs.remove(keyUserId)).called(1);
      verify(() => mockPrefs.remove(keyUserRole)).called(1);
    });
  });
}