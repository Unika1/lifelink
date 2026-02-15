import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/hospital/data/repositories/hospital_repository.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:riverpod/riverpod.dart';

// Provider
final getHospitalInventoryUsecaseProvider =
    Provider<GetHospitalInventoryUsecase>((ref) {
  final repository = ref.read(hospitalRepositoryProvider);
  return GetHospitalInventoryUsecase(repository: repository);
});

class GetHospitalInventoryUsecase
    implements UsecaseWithParams<List<BloodInventoryEntity>, String> {
  final IHospitalRepository _repository;

  GetHospitalInventoryUsecase({required IHospitalRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<BloodInventoryEntity>>> call(
      String hospitalId) {
    return _repository.getHospitalInventory(hospitalId);
  }
}
