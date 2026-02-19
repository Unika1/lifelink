import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/presentation/state/blood_bank_state.dart';
import 'package:lifelink/feature/blood_banks/presentation/view_model/blood_bank_viewmodel.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_questionnaire_screen.dart';
import 'package:lifelink/theme/app_theme.dart';

class BloodBankMapScreen extends ConsumerStatefulWidget {
  const BloodBankMapScreen({
    super.key,
    this.enableTileLayer = true,
  });

  final bool enableTileLayer;

  @override
  ConsumerState<BloodBankMapScreen> createState() => _BloodBankMapScreenState();
}

class _BloodBankMapScreenState extends ConsumerState<BloodBankMapScreen> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  String? _selectedBloodType;

  static const LatLng _defaultLocation = LatLng(27.7172, 85.3240);
  static const double _nearbyRadiusKm = 25;

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location services are disabled';
        });
        await ref.read(bloodBankViewModelProvider.notifier).getAllBloodBanks();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationError = 'Location permission denied';
          });
          await ref.read(bloodBankViewModelProvider.notifier).getAllBloodBanks();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location permission permanently denied';
        });
        await ref.read(bloodBankViewModelProvider.notifier).getAllBloodBanks();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 14);
      await ref.read(bloodBankViewModelProvider.notifier).getAllBloodBanks(
            latitude: position.latitude,
            longitude: position.longitude,
        radiusKm: _nearbyRadiusKm,
          );
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Could not get location';
      });

      await ref.read(bloodBankViewModelProvider.notifier).getAllBloodBanks();
    }
  }

  /// Filter blood banks by selected blood type
  List<BloodBankEntity> _filterByBloodType(List<BloodBankEntity> bloodBanks) {
    if (_selectedBloodType == null) {
      return bloodBanks;
    }

    return bloodBanks.where((bloodBank) {
      if (bloodBank.bloodInventory.isEmpty) {
        return true;
      }

      return bloodBank.bloodInventory.any(
        (inv) => inv.bloodType == _selectedBloodType && inv.unitsAvailable > 0,
      );
    }).toList();
  }

  List<BloodBankEntity> _filterNearbyBloodBanks(List<BloodBankEntity> bloodBanks) {
    if (_currentPosition == null) {
      return bloodBanks;
    }

    final maxDistanceMeters = _nearbyRadiusKm * 1000;

    return bloodBanks.where((bloodBank) {
      if (bloodBank.location == null) {
        return false;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        bloodBank.location!.latitude,
        bloodBank.location!.longitude,
      );

      return distanceInMeters <= maxDistanceMeters;
    }).toList();
  }

  int _getUnitsForType(BloodBankEntity bloodBank, String bloodType) {
    final match = bloodBank.bloodInventory.where(
      (inv) => inv.bloodType == bloodType,
    );
    if (match.isEmpty) return 0;
    return match.first.unitsAvailable;
  }

  List<Marker> _buildMarkers(List<BloodBankEntity> bloodBanks) {
    final markers = <Marker>[];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
      );
    }

    final nearby = _filterNearbyBloodBanks(bloodBanks);
    final filtered = _filterByBloodType(nearby);

    for (final bloodBank in filtered) {
      if (bloodBank.location != null && bloodBank.id != null) {
        markers.add(
          Marker(
            point: LatLng(
              bloodBank.location!.latitude,
              bloodBank.location!.longitude,
            ),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showBloodBankBottomSheet(bloodBank),
              child: const Icon(
                Icons.bloodtype,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _showBloodBankBottomSheet(BloodBankEntity bloodBank) {
    final isExternalSource = bloodBank.id?.startsWith('osm_') ?? false;
    final distance = bloodBank.location != null
        ? _calculateDistance(bloodBank.location!)
        : null;

    final availableTypes = bloodBank.bloodInventory
        .where((inv) => inv.unitsAvailable > 0)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bloodtype,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bloodBank.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${bloodBank.address.city}, ${bloodBank.address.state}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: bloodBank.email,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: bloodBank.phoneNumber,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.location_city,
                      label: 'Address',
                      value: bloodBank.address.fullAddress,
                    ),
                    const SizedBox(height: 14),
                    if (availableTypes.isNotEmpty) ...[
                      const Text(
                        'Available Blood Types:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: availableTypes.map((inv) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${inv.bloodType}: ${inv.unitsAvailable} units',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else
                      Text(
                        'No blood stock data available',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    if (isExternalSource) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Live map result (stock and request data may be unavailable).',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (!isExternalSource)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EligibilityQuestionnaireScreen(
                                  hospitalId: bloodBank.id,
                                  hospitalName: bloodBank.name,
                                  requestType: 'blood',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.bloodtype),
                          label: const Text(
                            'Request Blood',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final safeValue = value.trim().isEmpty ? 'Not available' : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppTheme.textColor),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: safeValue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDistance(BloodBankLocationEntity location) {
    if (_currentPosition == null) return '';

    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      location.latitude,
      location.longitude,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  List<BloodBankEntity> _sortByDistance(List<BloodBankEntity> bloodBanks) {
    if (_currentPosition == null) return bloodBanks;

    final sortable = bloodBanks.where((h) => h.location != null).toList();
    final noLocation = bloodBanks.where((h) => h.location == null).toList();

    sortable.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.location!.latitude,
        a.location!.longitude,
      );
      final distB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.location!.latitude,
        b.location!.longitude,
      );
      return distA.compareTo(distB);
    });

    return [...sortable, ...noLocation];
  }

  @override
  Widget build(BuildContext context) {
    final bloodBankState = ref.watch(bloodBankViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Blood Banks'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Blood type filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedBloodType == null,
                    onSelected: (_) {
                      setState(() => _selectedBloodType = null);
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                ),
                ..._bloodTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: _selectedBloodType == type,
                      onSelected: (_) {
                        setState(() {
                          _selectedBloodType = _selectedBloodType == type
                              ? null
                              : type;
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  );
                }),
              ],
            ),
          ),
          // Map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : _defaultLocation,
                    initialZoom: 13,
                  ),
                  children: [
                    if (widget.enableTileLayer)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.unika.lifelink',
                      ),
                    MarkerLayer(
                      markers: _buildMarkers(bloodBankState.bloodBanks),
                    ),
                  ],
                ),
                if (_isLoadingLocation)
                  Container(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(height: 12),
                          Text('Getting your location...'),
                        ],
                      ),
                    ),
                  ),
                if (_locationError != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Blood bank list below map
          Expanded(child: _buildBloodBankList(bloodBankState)),
        ],
      ),
    );
  }

  Widget _buildBloodBankList(BloodBankState bloodBankState) {
    if (bloodBankState.status == BloodBankStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (bloodBankState.status == BloodBankStatus.error) {
      return Center(
        child: Text(
          bloodBankState.errorMessage ?? 'Failed to load blood banks',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final nearby = _filterNearbyBloodBanks(bloodBankState.bloodBanks);
    final filtered = _filterByBloodType(nearby);
    final bloodBanks = _sortByDistance(filtered);

    if (bloodBanks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bloodtype_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedBloodType != null
                  ? 'No blood banks with $_selectedBloodType stock'
                  : 'No blood banks found within ${_nearbyRadiusKm.toInt()} km',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: bloodBanks.length,
      itemBuilder: (context, index) {
        final bloodBank = bloodBanks[index];
        final distance = bloodBank.location != null
            ? _calculateDistance(bloodBank.location!)
            : null;

        final availableCount = bloodBank.bloodInventory
            .where((inv) => inv.unitsAvailable > 0)
            .length;

        return GestureDetector(
          onTap: () => _showBloodBankBottomSheet(bloodBank),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bloodtype,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bloodBank.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${bloodBank.address.city}, ${bloodBank.address.state}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (_selectedBloodType != null)
                        Text(
                          '$_selectedBloodType: ${_getUnitsForType(bloodBank, _selectedBloodType!)} units',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      else
                        Text(
                          availableCount > 0
                              ? '$availableCount blood types available'
                              : 'Stock data unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
