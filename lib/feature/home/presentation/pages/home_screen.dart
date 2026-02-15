import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light/light.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_banks/presentation/pages/blood_bank_map_screen.dart';
import 'package:lifelink/feature/hospital/presentation/pages/hospital_map_screen.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<int>? _lightSensorSubscription;

  bool _isLoggingOutByShake = false;
  DateTime? _lastShakeLogoutAt;
  String _currentLocationText = 'Getting location...';
  final Dio _geoDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'lifelink-mobile-app/1.0',
      },
    ),
  );

  String _lightStatus = 'Unknown';
  int _luxValue = 0;
  double _appBrightness = 0.6;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _startShakeSensor();
    _startLightSensor();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _lightSensorSubscription?.cancel();
    super.dispose();
  }

  bool get _supportsSensorPlugins {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _currentLocationText = 'Location service off';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _currentLocationText = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final placeName = await _resolvePlaceName(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentLocationText =
            placeName ??
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentLocationText = 'Location unavailable';
      });
    }
  }

  Future<String?> _resolvePlaceName({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _geoDio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'addressdetails': 1,
        },
      );

      final data = response.data;
      if (data is! Map) return null;

      final address = (data['address'] as Map?)?.cast<String, dynamic>();
      if (address == null) return null;

      final locality =
          address['suburb']?.toString() ??
          address['neighbourhood']?.toString() ??
          address['city_district']?.toString() ??
          address['town']?.toString() ??
          address['city']?.toString() ??
          address['municipality']?.toString();

      final city =
          address['city']?.toString() ??
          address['town']?.toString() ??
          address['municipality']?.toString();

      final rawPlace = locality ?? city;
      if (rawPlace == null || rawPlace.trim().isEmpty) {
        return null;
      }

      final normalized = rawPlace.trim();
      if (normalized.contains('-')) {
        return normalized.split('-').first.trim();
      }
      if (normalized.contains(',')) {
        return normalized.split(',').first.trim();
      }
      return normalized;
    } catch (_) {
      return null;
    }
  }

  void _startShakeSensor() {
    if (!_supportsSensorPlugins) return;

    _accelerometerSubscription = accelerometerEventStream().listen(
      (event) {
        final magnitude =
            (event.x * event.x) + (event.y * event.y) + (event.z * event.z);
        final strongShake = magnitude > 300;

        if (strongShake) {
          _handleShakeLogout();
        }
      },
      onError: (_) {
        // Ignore plugin stream errors on unsupported devices.
      },
    );
  }

  Future<void> _handleShakeLogout() async {
    if (_isLoggingOutByShake) return;

    final now = DateTime.now();
    if (_lastShakeLogoutAt != null &&
        now.difference(_lastShakeLogoutAt!) < const Duration(seconds: 5)) {
      return;
    }

    _isLoggingOutByShake = true;
    _lastShakeLogoutAt = now;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shake detected. Logging out...')),
      );
    }

    await ref.read(authViewModelProvider.notifier).logout();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _startLightSensor() {
    if (!_supportsSensorPlugins) {
      if (!mounted) return;
      setState(() {
        _lightStatus = 'Unsupported';
      });
      return;
    }

    try {
      final light = Light();
      _lightSensorSubscription = light.lightSensorStream.listen(
        (lux) async {
          final int normalizedLux = lux < 0 ? 0 : lux;

          double targetBrightness;
          String status;

          if (normalizedLux < 20) {
            targetBrightness = 0.25;
            status = 'Dim';
          } else if (normalizedLux < 100) {
            targetBrightness = 0.45;
            status = 'Low Indoor';
          } else if (normalizedLux < 500) {
            targetBrightness = 0.65;
            status = 'Normal';
          } else {
            targetBrightness = 0.9;
            status = 'Bright';
          }

          if ((targetBrightness - _appBrightness).abs() >= 0.05) {
            await ScreenBrightness().setScreenBrightness(targetBrightness);
          }

          if (!mounted) return;
          setState(() {
            _luxValue = normalizedLux;
            _lightStatus = status;
            _appBrightness = targetBrightness;
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _lightStatus = 'Unsupported';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lightStatus = 'Unsupported';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 3,
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            children: [
              Image.asset(
                'assets/images/LifeLink-removebg-preview.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 10),
              Text(
                "LifeLink",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Notification clicked");
            },
            icon: Image.asset(
              'assets/icons/notification.png',
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth = constraints.maxWidth > 900
                  ? 900.0
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/location.png',
                                width: 26,
                                height: 26,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentLocationText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          card(
                            child: SizedBox(
                              height: 190,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Image.asset(
                                      'assets/images/measureoflife.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HospitalMapScreen(),
                                ),
                              );
                            },
                            child: card(
                              child: SizedBox(
                                height: 150,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/blood-drop.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "Nearby  hospital",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BloodBankMapScreen(),
                                      ),
                                    );
                                  },
                                  child: card(
                                    child: SizedBox(
                                      height: 175,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/blood-transfusion.png',
                                            width: 52,
                                            height: 52,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Blood banks",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HospitalMapScreen(),
                                      ),
                                    );
                                  },
                                  child: card(
                                    child: SizedBox(
                                      height: 175,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/hospital.png',
                                            width: 52,
                                            height: 52,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Hospital",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
