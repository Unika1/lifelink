import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepo); 
  });

  const tEmail = 'test@example.com';
  const tPassword = '123456';

  final tAuth = AuthEntity(
    authId: '1',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
  );

  test('Unit Test 1: should return AuthEntity when login is successful',
      () async {
    // Arrange
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => Right(tAuth));

    // Act
    final result = await usecase(
      const LoginUsecaseParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, Right(tAuth));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('Unit Test 2: should return Failure when login fails with invalid credentials',
      () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(
      const LoginUsecaseParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('Unit Test 3: should return Failure when network error occurs',
      () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Network error', statusCode: 500);
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(
      const LoginUsecaseParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('Unit Test 4: should return Failure when user account is not found',
      () async {
    // Arrange
    const tFailure = ApiFailure(message: 'User not found', statusCode: 404);
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(
      const LoginUsecaseParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('Unit Test 5: should return Failure when server error occurs',
      () async {
    // Arrange
    const tFailure = ApiFailure(message: 'Internal server error', statusCode: 503);
    when(() => mockRepo.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(
      const LoginUsecaseParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepo.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
