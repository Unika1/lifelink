import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_questionnaire_screen.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class NearbyHospitalPage extends ConsumerStatefulWidget {
  const NearbyHospitalPage({super.key});

  @override
  ConsumerState<NearbyHospitalPage> createState() => _NearbyHospitalPageState();
}

class _NearbyHospitalPageState extends ConsumerState<NearbyHospitalPage> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;

  static const LatLng _defaultLocation = LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    ref.read(hospitalViewModelProvider.notifier).getAllHospitals();
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

      _mapController.move(LatLng(position.latitude, position.longitude), 14);
    } catch (_) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Could not get location';
      });
    }
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
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
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

  List<Marker> _buildMarkers(List<HospitalEntity> hospitals) {
    final markers = <Marker>[];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
      );
    }

    for (final hospital in hospitals) {
      if (hospital.location != null && hospital.id != null) {
        markers.add(
          Marker(
            point: LatLng(
              hospital.location!.latitude,
              hospital.location!.longitude,
            ),
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
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hospital.address.fullAddress,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (distance != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Distance: $distance',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => EligibilityQuestionnaireScreen(
                            hospitalId: hospital.id,
                            hospitalName: hospital.name,
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
                    child: const Text('Request Donation'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 12),
            Text('Getting your location...'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationErrorBanner() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _locationError!,
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hospitalState = ref.watch(hospitalViewModelProvider);
    final hospitals = _sortByDistance(hospitalState.hospitals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
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
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.unika.lifelink',
                    ),
                    MarkerLayer(markers: _buildMarkers(hospitalState.hospitals)),
                  ],
                ),
                if (_isLoadingLocation) _buildLocationLoadingOverlay(),
                if (_locationError != null) _buildLocationErrorBanner(),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location_nearby',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_currentPosition != null) {
                        _mapController.move(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          15,
                        );
                      } else {
                        _initializeLocation();
                      }
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hospitalState.status == HospitalStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      final distance = hospital.location != null
                          ? _calculateDistance(hospital.location!)
                          : null;

                      return GestureDetector(
                        onTap: () => _showHospitalBottomSheet(hospital),
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
                                child: hospital.imageUrl != null &&
                                        hospital.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          ApiEndpoints.fullImageUrl(hospital.imageUrl!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.local_hospital,
                                            color: AppTheme.primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.local_hospital,
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
                                      hospital.name,
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
                                      '${hospital.address.city}, ${hospital.address.state}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}