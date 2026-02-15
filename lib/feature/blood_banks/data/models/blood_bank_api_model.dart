import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/hospital/data/models/hospital_api_model.dart'
    as hospital_model;

class BloodInventoryApiModel {
    final String bloodType;
    final int unitsAvailable;
    final DateTime? lastUpdated;

    BloodInventoryApiModel({
        required this.bloodType,
        required this.unitsAvailable,
        this.lastUpdated,
    });

    factory BloodInventoryApiModel.fromHospitalModel(
        hospital_model.BloodInventoryApiModel source,
    ) {
        return BloodInventoryApiModel(
            bloodType: source.bloodType,
            unitsAvailable: source.unitsAvailable,
            lastUpdated: source.lastUpdated,
        );
    }

    BloodInventoryEntity toEntity() {
        return BloodInventoryEntity(
            bloodType: bloodType,
            unitsAvailable: unitsAvailable,
            lastUpdated: lastUpdated,
        );
    }

    factory BloodInventoryApiModel.fromJson(Map<String, dynamic> json) {
        return BloodInventoryApiModel(
            bloodType: json['bloodType']?.toString() ?? '',
            unitsAvailable: _toInt(json['unitsAvailable']),
            lastUpdated: _parseDateTime(json['lastUpdated']),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'bloodType': bloodType,
            'unitsAvailable': unitsAvailable,
            'lastUpdated': lastUpdated?.toIso8601String(),
        };
    }
}

class BloodBankAddressApiModel {
    final String street;
    final String city;
    final String state;
    final String zipCode;
    final String country;

    BloodBankAddressApiModel({
        required this.street,
        required this.city,
        required this.state,
        required this.zipCode,
        required this.country,
    });

    factory BloodBankAddressApiModel.fromHospitalModel(
        hospital_model.HospitalAddressApiModel source,
    ) {
        return BloodBankAddressApiModel(
            street: source.street,
            city: source.city,
            state: source.state,
            zipCode: source.zipCode,
            country: source.country,
        );
    }

    BloodBankAddressEntity toEntity() {
        return BloodBankAddressEntity(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
        );
    }

    factory BloodBankAddressApiModel.fromJson(Map<String, dynamic> json) {
        return BloodBankAddressApiModel(
            street: json['street']?.toString() ?? '',
            city: json['city']?.toString() ?? '',
            state: json['state']?.toString() ?? '',
            zipCode: json['zipCode']?.toString() ?? '',
            country: json['country']?.toString() ?? 'Nepal',
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
}

class BloodBankLocationApiModel {
    final double latitude;
    final double longitude;

    BloodBankLocationApiModel({
        required this.latitude,
        required this.longitude,
    });

    factory BloodBankLocationApiModel.fromHospitalModel(
        hospital_model.HospitalLocationApiModel source,
    ) {
        return BloodBankLocationApiModel(
            latitude: source.latitude,
            longitude: source.longitude,
        );
    }

    BloodBankLocationEntity toEntity() {
        return BloodBankLocationEntity(
            latitude: latitude,
            longitude: longitude,
        );
    }

    factory BloodBankLocationApiModel.fromJson(Map<String, dynamic> json) {
        return BloodBankLocationApiModel(
            latitude: _toDouble(json['latitude']),
            longitude: _toDouble(json['longitude']),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'latitude': latitude,
            'longitude': longitude,
        };
    }
}

class BloodBankApiModel {
    final String? id;
    final String name;
    final String email;
    final String phoneNumber;
    final BloodBankAddressApiModel address;
    final BloodBankLocationApiModel? location;
    final List<BloodInventoryApiModel> bloodInventory;
    final String? licenseNumber;
    final String? imageUrl;
    final bool isActive;
    final String? userId;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    BloodBankApiModel({
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

    factory BloodBankApiModel.fromJson(Map<String, dynamic> json) {
        final inventory = (json['bloodInventory'] as List?) ?? const [];

        return BloodBankApiModel(
            id: json['_id']?.toString() ?? json['id']?.toString(),
            name: json['name']?.toString() ?? '',
            email: json['email']?.toString() ?? '',
            phoneNumber: json['phoneNumber']?.toString() ?? '',
            address: BloodBankAddressApiModel.fromJson(
                (json['address'] as Map?)?.cast<String, dynamic>() ??
                    <String, dynamic>{},
            ),
            location: json['location'] == null
                ? null
                : BloodBankLocationApiModel.fromJson(
                    (json['location'] as Map).cast<String, dynamic>(),
                ),
            bloodInventory: inventory
                .whereType<Map>()
                .map(
                    (item) => BloodInventoryApiModel.fromJson(
                        item.cast<String, dynamic>(),
                    ),
                )
                .toList(),
            licenseNumber: json['licenseNumber']?.toString(),
            imageUrl: json['imageUrl']?.toString(),
            isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
            userId: json['userId']?.toString(),
            createdAt: _parseDateTime(json['createdAt']),
            updatedAt: _parseDateTime(json['updatedAt']),
        );
    }

    factory BloodBankApiModel.fromHospitalModel(
        hospital_model.HospitalApiModel source,
    ) {
        return BloodBankApiModel(
            id: source.id,
            name: source.name,
            email: source.email,
            phoneNumber: source.phoneNumber,
            address: BloodBankAddressApiModel.fromHospitalModel(source.address),
            location: source.location == null
                    ? null
                    : BloodBankLocationApiModel.fromHospitalModel(source.location!),
            bloodInventory: source.bloodInventory
                    .map(
                        (inventory) => BloodInventoryApiModel(
                            bloodType: inventory.bloodType,
                            unitsAvailable: inventory.unitsAvailable,
                            lastUpdated: inventory.lastUpdated,
                        ),
                    )
                    .toList(),
            licenseNumber: source.licenseNumber,
            imageUrl: source.imageUrl,
            isActive: source.isActive,
            userId: source.userId,
            createdAt: source.createdAt,
            updatedAt: source.updatedAt,
        );
    }

    factory BloodBankApiModel.fromNominatim(Map<String, dynamic> json) {
        final displayName = json['display_name']?.toString() ?? '';
        final primaryName =
            json['name']?.toString() ??
            displayName.split(',').firstWhere((part) => part.trim().isNotEmpty,
                orElse: () => 'Blood Bank');

        final addressJson =
            (json['address'] as Map?)?.cast<String, dynamic>() ??
                <String, dynamic>{};

        final street = [
            addressJson['road']?.toString(),
            addressJson['suburb']?.toString(),
            addressJson['neighbourhood']?.toString(),
        ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

        final city =
            addressJson['city']?.toString() ??
            addressJson['town']?.toString() ??
            addressJson['municipality']?.toString() ??
            addressJson['county']?.toString() ??
            'Unknown';

        final state =
            addressJson['state']?.toString() ??
            addressJson['province']?.toString() ??
            'Unknown';

        final postalCode = addressJson['postcode']?.toString() ?? '';
        final country = addressJson['country']?.toString() ?? 'Nepal';

        final lat = _toDouble(json['lat']);
        final lon = _toDouble(json['lon']);

        final osmType = json['osm_type']?.toString() ?? 'osm';
        final osmId = json['osm_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

        return BloodBankApiModel(
            id: 'osm_${osmType}_$osmId',
            name: primaryName.trim().isEmpty ? 'Blood Bank' : primaryName.trim(),
            email: '',
            phoneNumber: '',
            address: BloodBankAddressApiModel(
                street: street,
                city: city,
                state: state,
                zipCode: postalCode,
                country: country,
            ),
            location: BloodBankLocationApiModel(latitude: lat, longitude: lon),
            bloodInventory: const [],
            licenseNumber: null,
            imageUrl: null,
            isActive: true,
            userId: null,
            createdAt: null,
            updatedAt: null,
        );
    }

    Map<String, dynamic> toJson() {
        return {
            '_id': id,
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'address': address.toJson(),
            'location': location?.toJson(),
            'bloodInventory': bloodInventory.map((item) => item.toJson()).toList(),
            'licenseNumber': licenseNumber,
            'imageUrl': imageUrl,
            'isActive': isActive,
            'userId': userId,
            'createdAt': createdAt?.toIso8601String(),
            'updatedAt': updatedAt?.toIso8601String(),
        };
    }

    BloodBankEntity toEntity() {
        return BloodBankEntity(
            id: id,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            address: address.toEntity(),
            location: location?.toEntity(),
            bloodInventory: bloodInventory.map((item) => item.toEntity()).toList(),
            licenseNumber: licenseNumber,
            imageUrl: imageUrl,
            isActive: isActive,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
        );
    }
}

DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
        return null;
    }
    return DateTime.tryParse(value.toString());
}

int _toInt(dynamic value) {
    if (value is int) {
        return value;
    }
    if (value is num) {
        return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
    if (value is double) {
        return value;
    }
    if (value is num) {
        return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
