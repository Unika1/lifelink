import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository{
  Future<Either<Failure,bool>>register(AuthEntity entity);
  Future<Either<Failure,AuthEntity>>login(String email,String password);
  Future<Either<Failure,AuthEntity>>getCurrentUser();
  Future<Either<Failure,bool>>logout();
  Future<Either<Failure, bool>> requestPasswordReset(String email);
  Future<Either<Failure, bool>> resetPassword(String token, String newPassword);
}