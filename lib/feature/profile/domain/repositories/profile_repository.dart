import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, String>> uploadProfileImage(File image);
  Future<Either<Failure, bool>> clearProfileCache();
  Future<Either<Failure, String?>> getCachedProfileImage();
}
