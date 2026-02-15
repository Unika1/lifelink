import 'package:lifelink/feature/nearbyhospital/domain/usecases/get_nearby_hospitals_usecase.dart';

import '../../domain/entities/hospital_entity.dart';


class HospitalViewModel {
  final GetNearbyHospitalsUsecase useCase;

  HospitalViewModel(this.useCase);

  Future<List<HospitalEntity>> fetchHospitals() async {
    return await useCase();
  }
}