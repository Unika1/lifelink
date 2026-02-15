import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
  final String? bloodGroup;
  final String? phoneNumber;
  final String? emergencyContact;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImageUrl,
    this.bloodGroup,
    this.phoneNumber,
    this.emergencyContact,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImageUrl,
    String? bloodGroup,
    String? phoneNumber,
    String? emergencyContact,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        firstName,
        lastName,
        email,
        profileImageUrl,
        bloodGroup,
        phoneNumber,
        emergencyContact,
        errorMessage,
      ];
}
