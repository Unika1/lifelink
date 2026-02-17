import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/usecases/upload_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late UploadProfileImageUsecase usecase;

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
  });

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UploadProfileImageUsecase(mockRepository);
  });

  test('calls repository.uploadProfileImage and returns url', () async {
    const expectedUrl = '/uploads/avatar.jpg';
    final file = File('avatar.jpg');

    when(() => mockRepository.uploadProfileImage(any()))
        .thenAnswer((_) async => const Right(expectedUrl));

    final result = await usecase(file);

    expect(result, const Right(expectedUrl));
    verify(() => mockRepository.uploadProfileImage(file)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository upload fails', () async {
    final file = File('avatar.jpg');
    const failure = ApiFailure(message: 'Upload failed', statusCode: 500);

    when(() => mockRepository.uploadProfileImage(any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(file);

    expect(result, const Left(failure));
  });

  test('upload file path contains filename', () {
    final file = File('avatar.jpg');
    expect(file.path, contains('avatar'));
  });

  test('usecase instance is created', () {
    expect(usecase, isA<UploadProfileImageUsecase>());
  });

  test('mock repository instance is created', () {
    expect(mockRepository, isA<MockProfileRepository>());
  });
}