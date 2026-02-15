import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';

enum EligibilityStatus { initial, loading, submitted, checked, error }

class EligibilityState extends Equatable {
  final EligibilityStatus status;
  final EligibilityResultEntity? result;
  final String? errorMessage;

  const EligibilityState({
    this.status = EligibilityStatus.initial,
    this.result,
    this.errorMessage,
  });

  EligibilityState copyWith({
    EligibilityStatus? status,
    EligibilityResultEntity? result,
    String? errorMessage,
  }) {
    return EligibilityState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
