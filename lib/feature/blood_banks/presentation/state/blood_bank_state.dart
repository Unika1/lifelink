import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';

enum BloodBankStatus { initial, loading, loaded, message, error }

class BloodBankState extends Equatable {
  final BloodBankStatus status;
  final List<BloodBankEntity> bloodBanks;
  final BloodBankEntity? selectedBloodBank;
  final List<BloodInventoryEntity> inventory;
  final String? errorMessage;
  final String? message;

  const BloodBankState({
    this.status = BloodBankStatus.initial,
    this.bloodBanks = const [],
    this.selectedBloodBank,
    this.inventory = const [],
    this.errorMessage,
    this.message,
  });

  BloodBankState copyWith({
    BloodBankStatus? status,
    List<BloodBankEntity>? bloodBanks,
    BloodBankEntity? selectedBloodBank,
    List<BloodInventoryEntity>? inventory,
    String? errorMessage,
    String? message,
  }) {
    return BloodBankState(
      status: status ?? this.status,
      bloodBanks: bloodBanks ?? this.bloodBanks,
      selectedBloodBank: selectedBloodBank ?? this.selectedBloodBank,
      inventory: inventory ?? this.inventory,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bloodBanks,
        selectedBloodBank,
        inventory,
        errorMessage,
        message,
      ];
}
