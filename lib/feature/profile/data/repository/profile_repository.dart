import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/services/connectivity/network_info.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/profile/data/datasource/local/profile_local_datasource.dart';
import 'package:lifelink/feature/profile/data/datasource/profile_datasource.dart';
import 'package:lifelink/feature/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:lifelink/feature/profile/data/models/profile_hive_model.dart';
import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    local: ref.read(profileLocalDatasourceProvider),
    remote: ref.read(profileRemoteDatasourceProvider),
    tokenService: ref.read(tokenServiceProvider),
    userSession: ref.read(userSessionServiceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final IProfileLocalDataSource _local;
  final IProfileRemoteDataSource _remote;
  final TokenService _tokenService;
  final UserSessionService _userSession;
  final NetworkInfo _networkInfo;

  ProfileRepository({
    required IProfileLocalDataSource local,
    required IProfileRemoteDataSource remote,
    required TokenService tokenService,
    required UserSessionService userSession,
    required NetworkInfo networkInfo,
  })  : _local = local,
        _remote = remote,
        _tokenService = tokenService,
        _userSession = userSession,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final userId = _userSession.getUserId();
    if (userId == null) {
      return const Left(LocalDatabaseFailure(message: "No user session found"));
    }

    // cache first
    final cached = await _local.getCachedProfile(userId);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    // If no cache, hit API 
    final token = _tokenService.getToken();
    if (token == null) {
      return const Left(ApiFailure(message: "Token not found"));
    }

    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final apiProfile = await _remote.getMe(token);
      final entity = apiProfile.toEntity();
      await _local.cacheProfile(ProfileHiveModel.fromEntity(entity));
      return Right(entity);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File image) async {
    final token = _tokenService.getToken();
    final userId = _userSession.getUserId();

    if (token == null || userId == null) {
      return const Left(ApiFailure(message: "Login required"));
    }

    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final imageUrl = await _remote.uploadProfilePhoto(token: token, image: image);

      // update cache
      await _local.updateCachedImage(userId, imageUrl);

      return Right(imageUrl);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clearProfileCache() async {
    final userId = _userSession.getUserId();
    if (userId == null) {
      return const Left(LocalDatabaseFailure(message: "No user session found"));
    }
    final ok = await _local.clearProfile(userId);
    return Right(ok);
  }

  @override
  Future<Either<Failure, String?>> getCachedProfileImage() async {
    final userId = _userSession.getUserId();
    if (userId == null) {
      return const Left(LocalDatabaseFailure(message: "No user session found"));
    }
    final cached = await _local.getCachedProfile(userId);
    return Right(cached?.imageUrl);
  }
  
}
