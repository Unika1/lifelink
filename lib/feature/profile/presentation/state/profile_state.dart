import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? profileImageUrl;
  final String? bloodGroup;
  final String? phoneNumber;
  final String? emergencyContact;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileImageUrl,
    this.bloodGroup,
    this.phoneNumber,
    this.emergencyContact,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? profileImageUrl,
    String? bloodGroup,
    String? phoneNumber,
    String? emergencyContact,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profileImageUrl, bloodGroup,phoneNumber,emergencyContact, errorMessage];
}
