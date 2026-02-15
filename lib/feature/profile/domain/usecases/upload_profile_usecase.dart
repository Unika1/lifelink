import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/profile/data/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';

final uploadProfileImageUsecaseProvider =
    Provider<UploadProfileImageUsecase>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return UploadProfileImageUsecase(repo);
});

class UploadProfileImageUsecase implements UsecaseWithParams<String, File> {
  final IProfileRepository _repo;
  UploadProfileImageUsecase(this._repo);

  @override
  Future<Either<Failure, String>> call(File params) {
    return _repo.uploadProfileImage(params);
  }
}
