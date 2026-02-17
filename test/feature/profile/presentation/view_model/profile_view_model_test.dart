import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/profile/data/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/usecases/upload_profile_usecase.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockUploadProfileImageUsecase extends Mock
    implements UploadProfileImageUsecase {}

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockUploadProfileImageUsecase mockUploadUsecase;
  late MockProfileRepository mockRepository;
  late ProviderContainer container;

  const tProfile = ProfileEntity(
    userId: 'user-1',
    firstName: 'Sita',
    lastName: 'Sharma',
    email: 'sita@mail.com',
    bloodGroup: 'A+',
    phoneNumber: '9800000000',
  );

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
  });

  setUp(() {
    mockUploadUsecase = MockUploadProfileImageUsecase();
    mockRepository = MockProfileRepository();

    when(() => mockRepository.getProfile())
        .thenAnswer((_) async => const Right(tProfile));
    when(() => mockRepository.updateProfile(any()))
        .thenAnswer((_) async => const Right({'ok': true}));
    when(() => mockUploadUsecase(any()))
        .thenAnswer((_) async => const Right('/uploads/new.jpg'));

    container = ProviderContainer(
      overrides: [
        uploadProfileImageUsecaseProvider.overrideWithValue(mockUploadUsecase),
        profileRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileViewModel', () {
    test('loads cached/remote profile into loaded state after build', () async {
      container.read(profileViewModelProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(profileViewModelProvider);
      expect(state.status, ProfileStatus.loaded);
      expect(state.firstName, 'Sita');
      expect(state.email, 'sita@mail.com');
    });

    test('setBloodGroup updates state on success', () async {
      container.read(profileViewModelProvider);
      await Future<void>.delayed(Duration.zero);

      await container
          .read(profileViewModelProvider.notifier)
          .setBloodGroup('B+');

      final state = container.read(profileViewModelProvider);
      expect(state.status, ProfileStatus.loaded);
      expect(state.bloodGroup, 'B+');
    });

    test('uploadProfileImage sets error state on failure', () async {
      when(() => mockUploadUsecase(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Upload failed')),
      );

      await container
          .read(profileViewModelProvider.notifier)
          .uploadProfileImage(File('x.jpg'));

      final state = container.read(profileViewModelProvider);
      expect(state.status, ProfileStatus.error);
      expect(state.errorMessage, 'Upload failed');
    });

    test('setPhoneNumber updates state on success', () async {
      container.read(profileViewModelProvider);
      await Future<void>.delayed(Duration.zero);

      await container
          .read(profileViewModelProvider.notifier)
          .setPhoneNumber('9811111111');

      final state = container.read(profileViewModelProvider);
      expect(state.status, ProfileStatus.loaded);
      expect(state.phoneNumber, '9811111111');
    });

    test('profile fixture has expected full identity values', () {
      expect(tProfile.firstName, 'Sita');
      expect(tProfile.lastName, 'Sharma');
      expect(tProfile.email, contains('@'));
    });
  });
}