import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/pages/hospital_detail_screen.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class HospitalMapScreen extends ConsumerStatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  ConsumerState<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends ConsumerState<HospitalMapScreen> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;

  // Default to Kathmandu, Nepal
  static const LatLng _defaultLocation = LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    Future.microtask(() {
      ref.read(hospitalViewModelProvider.notifier).getAllHospitals();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location services are disabled';
        });
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
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationError = 'Location permission permanently denied';
        });
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

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Could not get location';
      });
    }
  }

  List<Marker> _buildMarkers(List<HospitalEntity> hospitals) {
    final markers = <Marker>[];

    // User location marker (blue)
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
              _currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
      );
    }

    // Hospital markers (red)
    for (final hospital in hospitals) {
      if (hospital.location != null && hospital.id != null) {
        markers.add(
          Marker(
            point: LatLng(
                hospital.location!.latitude, hospital.location!.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showHospitalBottomSheet(hospital),
              child: const Icon(
                Icons.local_hospital,
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

  void _showHospitalBottomSheet(HospitalEntity hospital) {
    final distance = hospital.location != null
        ? _calculateDistance(hospital.location!)
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: const Icon(Icons.local_hospital,
                        color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hospital.name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor)),
                        const SizedBox(height: 2),
                        Text(
                            '${hospital.address.city}, ${hospital.address.state}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(distance,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(hospital.phoneNumber,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HospitalDetailScreen(hospitalId: hospital.id!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Details',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _calculateDistance(HospitalLocationEntity location) {
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

  List<HospitalEntity> _sortByDistance(List<HospitalEntity> hospitals) {
    if (_currentPosition == null) return hospitals;

    final sortable = hospitals.where((h) => h.location != null).toList();
    final noLocation = hospitals.where((h) => h.location == null).toList();

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
    final hospitalState = ref.watch(hospitalViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map (OpenStreetMap — free, no API key)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : _defaultLocation,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.unika.lifelink',
                    ),
                    MarkerLayer(
                      markers: _buildMarkers(hospitalState.hospitals),
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
                              color: AppTheme.primaryColor),
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
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off,
                              size: 18, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_locationError!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.orange)),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_currentPosition != null) {
                        _mapController.move(
                          LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          15,
                        );
                      } else {
                        _initializeLocation();
                      }
                    },
                    child: const Icon(Icons.my_location,
                        color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          // Hospital list below map
          Expanded(child: _buildHospitalList(hospitalState)),
        ],
      ),
    );
  }

  Widget _buildHospitalList(HospitalState hospitalState) {
    if (hospitalState.status == HospitalStatus.loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (hospitalState.status == HospitalStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(hospitalState.errorMessage ?? 'Failed to load hospitals',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(hospitalViewModelProvider.notifier)
                    .getAllHospitals();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final hospitals = _sortByDistance(hospitalState.hospitals);

    if (hospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('No hospitals found',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        final distance = hospital.location != null
            ? _calculateDistance(hospital.location!)
            : null;

        return GestureDetector(
          onTap: () {
            if (hospital.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HospitalDetailScreen(hospitalId: hospital.id!),
                ),
              );
            }
          },
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
                  child: const Icon(Icons.local_hospital,
                      color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                          '${hospital.address.city}, ${hospital.address.state}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (distance != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(distance,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor)),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
