import 'package:equatable/equatable.dart';

class BloodInventoryEntity extends Equatable {
	final String bloodType;
	final int unitsAvailable;
	final DateTime? lastUpdated;

	const BloodInventoryEntity({
		required this.bloodType,
		required this.unitsAvailable,
		this.lastUpdated,
	});

	@override
	List<Object?> get props => [bloodType, unitsAvailable, lastUpdated];
}

class BloodBankAddressEntity extends Equatable {
	final String street;
	final String city;
	final String state;
	final String zipCode;
	final String country;

	const BloodBankAddressEntity({
		required this.street,
		required this.city,
		required this.state,
		required this.zipCode,
		this.country = 'Nepal',
	});

	String get fullAddress => '$street, $city, $state $zipCode';

	@override
	List<Object?> get props => [street, city, state, zipCode, country];
}

class BloodBankLocationEntity extends Equatable {
	final double latitude;
	final double longitude;

	const BloodBankLocationEntity({
		required this.latitude,
		required this.longitude,
	});

	@override
	List<Object?> get props => [latitude, longitude];
}

class BloodBankEntity extends Equatable {
	final String? id;
	final String name;
	final String email;
	final String phoneNumber;
	final BloodBankAddressEntity address;
	final BloodBankLocationEntity? location;
	final List<BloodInventoryEntity> bloodInventory;
	final String? licenseNumber;
	final String? imageUrl;
	final bool isActive;
	final String? userId;
	final DateTime? createdAt;
	final DateTime? updatedAt;

	const BloodBankEntity({
		this.id,
		required this.name,
		required this.email,
		required this.phoneNumber,
		required this.address,
		this.location,
		this.bloodInventory = const [],
		this.licenseNumber,
		this.imageUrl,
		this.isActive = true,
		this.userId,
		this.createdAt,
		this.updatedAt,
	});

	@override
	List<Object?> get props => [
				id,
				name,
				email,
				phoneNumber,
				address,
				location,
				bloodInventory,
				licenseNumber,
				imageUrl,
				isActive,
				userId,
				createdAt,
				updatedAt,
			];
}
