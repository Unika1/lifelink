import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/auth/data/datasources/auth_datasource.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockAuthLocalDataSource mockLocal;
  late MockAuthRemoteDataSource mockRemote;
  late MockTokenService mockTokenService;
  late AuthRepository repository;

  setUp(() {
    mockLocal = MockAuthLocalDataSource();
    mockRemote = MockAuthRemoteDataSource();
    mockTokenService = MockTokenService();

    repository = AuthRepository(
      authDataSource: mockLocal,
      authRemoteDataSource: mockRemote,
      tokenService: mockTokenService,
    );
  });

  group('changePassword', () {
    test('returns ApiFailure when token is missing', () async {
      when(() => mockTokenService.getToken()).thenReturn(null);

      final result = await repository.changePassword('old12345', 'new12345');

      expect(result, const Left(ApiFailure(message: 'Login required')));
      verify(() => mockTokenService.getToken()).called(1);
      verifyNever(() => mockRemote.changePassword(any(), any(), any()));
    });

    test('returns Right(true) when remote change password succeeds', () async {
      when(() => mockTokenService.getToken()).thenReturn('token-123');
      when(
        () => mockRemote.changePassword('token-123', 'old12345', 'new12345'),
      ).thenAnswer((_) async {});

      final result = await repository.changePassword('old12345', 'new12345');

      expect(result, const Right(true));
      verify(() => mockTokenService.getToken()).called(1);
      verify(
        () => mockRemote.changePassword('token-123', 'old12345', 'new12345'),
      ).called(1);
    });

    test('returns API message from DioException map response', () async {
      when(() => mockTokenService.getToken()).thenReturn('token-123');
      when(
        () => mockRemote.changePassword('token-123', 'old12345', 'new12345'),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/change-password'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/change-password'),
            statusCode: 400,
            data: {'message': 'Current password is incorrect'},
          ),
        ),
      );

      final result = await repository.changePassword('old12345', 'new12345');

      expect(
        result,
        const Left(
          ApiFailure(
            message: 'Current password is incorrect',
            statusCode: 400,
          ),
        ),
      );
    });
  });
}