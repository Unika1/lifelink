import '../entities/hospital_entity.dart';

abstract class IHospitalRepository {
  Future<List<HospitalEntity>> getNearbyHospitals();
}