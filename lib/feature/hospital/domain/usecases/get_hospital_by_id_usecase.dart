import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/hospital/data/repositories/hospital_repository.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:riverpod/riverpod.dart';

// Provider
final getHospitalByIdUsecaseProvider = Provider<GetHospitalByIdUsecase>((ref) {
  final repository = ref.read(hospitalRepositoryProvider);
  return GetHospitalByIdUsecase(repository: repository);
});

class GetHospitalByIdUsecase
    implements UsecaseWithParams<HospitalEntity, String> {
  final IHospitalRepository _repository;

  GetHospitalByIdUsecase({required IHospitalRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, HospitalEntity>> call(String hospitalId) {
    return _repository.getHospitalById(hospitalId);
  }
}
