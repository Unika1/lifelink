import '../entities/hospital_entity.dart';
import '../repositories/hospital_repository.dart';

class GetNearbyHospitalsUsecase {
  final IHospitalRepository repository;

  GetNearbyHospitalsUsecase(this.repository);

  Future<List<HospitalEntity>> call() async {
    return await repository.getNearbyHospitals();
  }
}
