import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/hospital/data/repositories/hospital_repository.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:riverpod/riverpod.dart';

class GetAllHospitalsParams extends Equatable {
  final String? city;
  final String? state;
  final String? bloodType;
  final bool? isActive;

  const GetAllHospitalsParams({
    this.city,
    this.state,
    this.bloodType,
    this.isActive,
  });

  @override
  List<Object?> get props => [city, state, bloodType, isActive];
}

// Provider
final getAllHospitalsUsecaseProvider = Provider<GetAllHospitalsUsecase>((ref) {
  final repository = ref.read(hospitalRepositoryProvider);
  return GetAllHospitalsUsecase(repository: repository);
});

class GetAllHospitalsUsecase
    implements
        UsecaseWithParams<List<HospitalEntity>, GetAllHospitalsParams> {
  final IHospitalRepository _repository;

  GetAllHospitalsUsecase({required IHospitalRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<HospitalEntity>>> call(
      GetAllHospitalsParams params) {
    return _repository.getAllHospitals(
      city: params.city,
      state: params.state,
      bloodType: params.bloodType,
      isActive: params.isActive,
    );
  }
}
