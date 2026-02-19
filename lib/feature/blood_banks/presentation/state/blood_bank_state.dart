import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';

enum BloodBankStatus { initial, loading, loaded, message, error }

const _bloodBankStateUnset = Object();

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
    Object? selectedBloodBank = _bloodBankStateUnset,
    List<BloodInventoryEntity>? inventory,
    Object? errorMessage = _bloodBankStateUnset,
    Object? message = _bloodBankStateUnset,
  }) {
    return BloodBankState(
      status: status ?? this.status,
      bloodBanks: bloodBanks ?? this.bloodBanks,
      selectedBloodBank: selectedBloodBank == _bloodBankStateUnset
          ? this.selectedBloodBank
          : selectedBloodBank as BloodBankEntity?,
      inventory: inventory ?? this.inventory,
      errorMessage: errorMessage == _bloodBankStateUnset
          ? this.errorMessage
          : errorMessage as String?,
      message: message == _bloodBankStateUnset
          ? this.message
          : message as String?,
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
