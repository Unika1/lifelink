import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';

enum HospitalStatus { initial, loading, loaded, error }

class HospitalState extends Equatable {
  final HospitalStatus status;
  final List<HospitalEntity> hospitals;
  final HospitalEntity? selectedHospital;
  final List<BloodInventoryEntity> inventory;
  final String? errorMessage;

  const HospitalState({
    this.status = HospitalStatus.initial,
    this.hospitals = const [],
    this.selectedHospital,
    this.inventory = const [],
    this.errorMessage,
  });

  HospitalState copyWith({
    HospitalStatus? status,
    List<HospitalEntity>? hospitals,
    HospitalEntity? selectedHospital,
    List<BloodInventoryEntity>? inventory,
    String? errorMessage,
  }) {
    return HospitalState(
      status: status ?? this.status,
      hospitals: hospitals ?? this.hospitals,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      inventory: inventory ?? this.inventory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        hospitals,
        selectedHospital,
        inventory,
        errorMessage,
      ];
}
