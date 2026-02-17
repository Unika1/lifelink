import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/services/connectivity/network_info.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/profile/data/datasources/profile_datasource.dart';
import 'package:lifelink/feature/profile/data/models/profile_api_model.dart';
import 'package:lifelink/feature/profile/data/models/profile_hive_model.dart';
import 'package:lifelink/feature/profile/data/repositories/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileLocalDataSource extends Mock implements IProfileLocalDataSource {}

class MockProfileRemoteDataSource extends Mock
    implements IProfileRemoteDataSource {}

class MockTokenService extends Mock implements TokenService {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockProfileLocalDataSource mockLocal;
  late MockProfileRemoteDataSource mockRemote;
  late MockTokenService mockTokenService;
  late MockUserSessionService mockUserSession;
  late MockNetworkInfo mockNetworkInfo;
  late ProfileRepository repository;

  final tCachedProfile = ProfileHiveModel(
    userId: 'user-1',
    firstName: 'Sita',
    lastName: 'Sharma',
    email: 'sita@mail.com',
    imageUrl: '/uploads/profile.jpg',
    bloodGroup: 'A+',
  );

  final tApiProfile = ProfileApiModel(
    userId: 'user-1',
    firstName: 'Sita',
    lastName: 'Sharma',
    email: 'sita@mail.com',
    imageUrl: '/uploads/profile.jpg',
    bloodGroup: 'A+',
  );

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(
      ProfileHiveModel(
        userId: 'fallback-user',
        firstName: 'Fallback',
        lastName: 'User',
        email: 'fallback@mail.com',
      ),
    );
  });

  setUp(() {
    mockLocal = MockProfileLocalDataSource();
    mockRemote = MockProfileRemoteDataSource();
    mockTokenService = MockTokenService();
    mockUserSession = MockUserSessionService();
    mockNetworkInfo = MockNetworkInfo();

    repository = ProfileRepository(
      local: mockLocal,
      remote: mockRemote,
      tokenService: mockTokenService,
      userSession: mockUserSession,
      networkInfo: mockNetworkInfo,
    );
  });

  group('ProfileRepository', () {
    test('getProfile returns cached profile when available', () async {
      when(() => mockUserSession.getUserId()).thenReturn('user-1');
      when(() => mockLocal.getCachedProfile('user-1'))
          .thenAnswer((_) async => tCachedProfile);

      final result = await repository.getProfile();

      expect(result, isA<Right<Failure, dynamic>>());
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (profile) {
          expect(profile.userId, 'user-1');
          expect(profile.firstName, 'Sita');
          expect(profile.bloodGroup, 'A+');
        },
      );
      verifyNever(() => mockRemote.getMe(any()));
    });

    test('getProfile returns ApiFailure when token is missing', () async {
      when(() => mockUserSession.getUserId()).thenReturn('user-1');
      when(() => mockLocal.getCachedProfile('user-1'))
          .thenAnswer((_) async => null);
      when(() => mockTokenService.getToken()).thenReturn(null);

      final result = await repository.getProfile();

      expect(result, const Left(ApiFailure(message: 'Token not found')));
    });

    test('uploadProfileImage returns image URL and updates cache', () async {
      const imageUrl = '/uploads/new-image.jpg';

      when(() => mockTokenService.getToken()).thenReturn('token-1');
      when(() => mockUserSession.getUserId()).thenReturn('user-1');
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.uploadProfilePhoto(
          token: 'token-1',
          image: any(named: 'image'),
        ),
      ).thenAnswer((_) async => imageUrl);
      when(() => mockLocal.updateCachedImage('user-1', imageUrl))
          .thenAnswer((_) async => true);

      final result = await repository.uploadProfileImage(File('dummy.jpg'));

      expect(result, const Right(imageUrl));
      verify(() => mockLocal.updateCachedImage('user-1', imageUrl)).called(1);
    });

    test('updateProfile returns no-internet failure when offline', () async {
      when(() => mockTokenService.getToken()).thenReturn('token-1');
      when(() => mockUserSession.getUserId()).thenReturn('user-1');
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.updateProfile({'bloodGroup': 'B+'});

      expect(
        result,
        const Left(ApiFailure(message: 'No internet connection')),
      );
      verifyNever(
        () => mockRemote.updateProfile(token: any(named: 'token'), data: any(named: 'data')),
      );
    });

    test('getProfile fetches remote and caches when no local cache', () async {
      when(() => mockUserSession.getUserId()).thenReturn('user-1');
      when(() => mockLocal.getCachedProfile('user-1'))
          .thenAnswer((_) async => null);
      when(() => mockTokenService.getToken()).thenReturn('token-1');
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getMe('token-1')).thenAnswer((_) async => tApiProfile);
      when(() => mockLocal.cacheProfile(any())).thenAnswer((_) async => true);

      final result = await repository.getProfile();

      expect(result, isA<Right<Failure, dynamic>>());
      verify(() => mockRemote.getMe('token-1')).called(1);
      verify(() => mockLocal.cacheProfile(any())).called(1);
    });
  });
}