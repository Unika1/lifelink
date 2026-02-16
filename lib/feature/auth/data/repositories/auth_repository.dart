import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/auth/data/datasources/auth_datasource.dart';
import 'package:lifelink/feature/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:lifelink/feature/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:lifelink/feature/auth/data/models/auth_api_model.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDataSource: ref.read(authLocalDatasourceProvider),
    authRemoteDataSource: ref.read(authRemoteProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource; // local
  final IAuthRemoteDataSource _authRemoteDataSource; // remote 
  final TokenService _tokenService;

  AuthRepository({
    required IAuthLocalDataSource authDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required TokenService tokenService,
  })  : _authDataSource = authDataSource,
        _authRemoteDataSource = authRemoteDataSource,
        _tokenService = tokenService;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final apiUser = await _authRemoteDataSource.login(email, password);

      if (apiUser == null) {
        return Left(ApiFailure(message: 'Invalid email or password'));
      }

      return Right(apiUser.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ?? 'Login failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final apiModel = AuthApiModel.fromEntity(entity);
      await _authRemoteDataSource.register(apiModel);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message']?.toString() ?? 'Registration failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    try {
      await _authRemoteDataSource.requestPasswordReset(email);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Password reset request failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      await _authRemoteDataSource.resetPassword(token, newPassword);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ?? 'Reset failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = _tokenService.getToken();
    if (token == null || token.isEmpty) {
      return const Left(ApiFailure(message: 'Login required'));
    }

    try {
      await _authRemoteDataSource.changePassword(
        token,
        currentPassword,
        newPassword,
      );
      return const Right(true);
    } on DioException catch (e) {
      String message = 'Change password failed';
      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        final apiMessage = responseData['message'];
        if (apiMessage != null && apiMessage.toString().trim().isNotEmpty) {
          message = apiMessage.toString();
        }
      } else if (responseData is String && responseData.trim().isNotEmpty) {
        message = responseData;
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }

      return Left(
        ApiFailure(
          message: message,
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
