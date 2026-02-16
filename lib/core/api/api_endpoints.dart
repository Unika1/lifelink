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

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ============ Auth ============
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String requestPasswordReset = '/auth/request-password-reset';
  static String resetPassword(String token) => '/auth/reset-password/$token';
  static const String changePassword = '/auth/change-password';

  // ============ Profile ============
  static const String updateProfile = '/auth/update-profile';
  static const String me = '/auth/me';

  // ============ Hospitals ============
  static const String hospitals = '/hospitals';
  static String hospitalById(String id) => '/hospitals/$id';
  static String hospitalInventory(String id) => '/hospitals/$id/inventory';
  static const String donors = '/hospitals/donors';

  // ============ Blood Requests ============
  static const String bloodRequests = '/requests';
  static String bloodRequestById(String id) => '/requests/$id';

  // ============ Organ Requests ============
  static const String organRequests = '/organ-requests';
  static String organRequestById(String id) => '/organ-requests/$id';

  // ============ Eligibility ============
  static const String eligibilitySubmit = '/eligibility/submit';
  static const String eligibilityCheck = '/eligibility/check';
  static const String eligibilityQuestionnaire = '/eligibility/questionnaire';

  /// If backend returns "/uploads/xyz.jpg"
  /// this makes "http://IP:5050/uploads/xyz.jpg"
  static String fullImageUrl(String imageUrlFromApi) {
    return '$imageBaseUrl$imageUrlFromApi';
  }
}
