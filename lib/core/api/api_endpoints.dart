import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;

  // Your PC IP address (same network as phone)
  static const String compIpAddress = "192.168.1.70";

  /// API base url
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';
    }

    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:5050/api';
    } else {
      // iOS simulator / desktop
      return 'http://localhost:5050/api';
    }
  }

  /// Image base url (static file server)
  static String get imageBaseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }

    if (kIsWeb) {
      return 'http://localhost:5050';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:5050';
    } else {
      return 'http://localhost:5050';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth ============
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // ============ Profile ============
  static const String updateProfile = '/auth/update-profile';
  static const String me = '/auth/me';

  /// If backend returns "/uploads/xyz.jpg"
  /// this makes "http://IP:5050/uploads/xyz.jpg"
  static String fullImageUrl(String imageUrlFromApi) {
    return '$imageBaseUrl$imageUrlFromApi';
  }
}
