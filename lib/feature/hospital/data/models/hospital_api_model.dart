import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';

class BloodInventoryApiModel {
  final String bloodType;
  final int unitsAvailable;
  final DateTime? lastUpdated;

  BloodInventoryApiModel({
    required this.bloodType,
    required this.unitsAvailable,
    this.lastUpdated,
  });

  factory BloodInventoryApiModel.fromJson(Map<String, dynamic> json) {
    return BloodInventoryApiModel(
      bloodType: json['bloodType'] ?? '',
      unitsAvailable: json['unitsAvailable'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'unitsAvailable': unitsAvailable,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  BloodInventoryEntity toEntity() {
    return BloodInventoryEntity(
      bloodType: bloodType,
      unitsAvailable: unitsAvailable,
      lastUpdated: lastUpdated,
    );
  }

  factory BloodInventoryApiModel.fromEntity(BloodInventoryEntity entity) {
    return BloodInventoryApiModel(
      bloodType: entity.bloodType,
      unitsAvailable: entity.unitsAvailable,
      lastUpdated: entity.lastUpdated,
    );
  }
}

class HospitalAddressApiModel {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  HospitalAddressApiModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Nepal',
  });

  factory HospitalAddressApiModel.fromJson(Map<String, dynamic> json) {
    return HospitalAddressApiModel(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? 'Nepal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  HospitalAddressEntity toEntity() {
    return HospitalAddressEntity(
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
  }

  factory HospitalAddressApiModel.fromEntity(HospitalAddressEntity entity) {
    return HospitalAddressApiModel(
      street: entity.street,
      city: entity.city,
      state: entity.state,
      zipCode: entity.zipCode,
      country: entity.country,
    );
  }
}

class HospitalLocationApiModel {
  final double latitude;
  final double longitude;

  HospitalLocationApiModel({
    required this.latitude,
    required this.longitude,
  });

  factory HospitalLocationApiModel.fromJson(Map<String, dynamic> json) {
    return HospitalLocationApiModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  HospitalLocationEntity toEntity() {
    return HospitalLocationEntity(
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory HospitalLocationApiModel.fromEntity(HospitalLocationEntity entity) {
    return HospitalLocationApiModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}

class HospitalApiModel {
  final String? id;
  final String name;
  final String email;
  final String phoneNumber;
  final HospitalAddressApiModel address;
  final HospitalLocationApiModel? location;
  final List<BloodInventoryApiModel> bloodInventory;
  final String? licenseNumber;
  final String? imageUrl;
  final bool isActive;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HospitalApiModel({
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

  factory HospitalApiModel.fromJson(Map<String, dynamic> json) {
    // Parse address
    final addressJson = json['address'];
    final address = addressJson is Map<String, dynamic>
        ? HospitalAddressApiModel.fromJson(addressJson)
        : HospitalAddressApiModel(
            street: '', city: '', state: '', zipCode: '');

    // Parse location (optional)
    HospitalLocationApiModel? location;
    final locationJson = json['location'];
    if (locationJson is Map<String, dynamic> &&
        locationJson['latitude'] != null &&
        locationJson['longitude'] != null) {
      location = HospitalLocationApiModel.fromJson(locationJson);
    }

    // Parse blood inventory
    final inventoryJson = json['bloodInventory'];
    final inventory = inventoryJson is List
        ? inventoryJson
            .map((e) =>
                BloodInventoryApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <BloodInventoryApiModel>[];

    return HospitalApiModel(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: address,
      location: location,
      bloodInventory: inventory,
      licenseNumber: json['licenseNumber'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'bloodInventory': bloodInventory.map((item) => item.toJson()).toList(),
      'isActive': isActive,
    };

    if (location != null) map['location'] = location!.toJson();
    if (licenseNumber != null && licenseNumber!.isNotEmpty) {
      map['licenseNumber'] = licenseNumber;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) map['imageUrl'] = imageUrl;
    if (userId != null && userId!.isNotEmpty) map['userId'] = userId;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) map['updatedAt'] = updatedAt!.toIso8601String();

    return map;
  }

  HospitalEntity toEntity() {
    return HospitalEntity(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address.toEntity(),
      location: location?.toEntity(),
      bloodInventory: bloodInventory.map((e) => e.toEntity()).toList(),
      licenseNumber: licenseNumber,
      imageUrl: imageUrl,
      isActive: isActive,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory HospitalApiModel.fromEntity(HospitalEntity entity) {
    return HospitalApiModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: HospitalAddressApiModel.fromEntity(entity.address),
      location: entity.location != null
          ? HospitalLocationApiModel.fromEntity(entity.location!)
          : null,
      bloodInventory: entity.bloodInventory
          .map((item) => BloodInventoryApiModel.fromEntity(item))
          .toList(),
      licenseNumber: entity.licenseNumber,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
