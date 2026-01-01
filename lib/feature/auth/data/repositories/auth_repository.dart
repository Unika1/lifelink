import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/auth/data/datasources/auth_datasource.dart';
import 'package:lifelink/feature/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider=Provider<IAuthRepository>((ref){
  return AuthRepository(
    authDataSource: ref.read(authLocalDatasourceProvider),
  );
});
class AuthRepository implements IAuthRepository{
  final IAuthDataSource _authDataSource;

  AuthRepository({required IAuthDataSource authDataSource}) : _authDataSource = authDataSource;

  
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser()async {
    try{
      final user=await _authDataSource.getCurrentUser();
      if(user!=null){
        final entity= user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'No user logged in'));
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password)async {
    try{
      final user= await _authDataSource.login(email, password);
      if(user!=null){
        final entity=user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout()async {
    try{
      final result=await _authDataSource.logout();
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    }catch (e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity)async {
    try{
      //model ma convert gareko
      final model=AuthHiveModel.fromEntity(entity);
      final result=await _authDataSource.register(model);
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}