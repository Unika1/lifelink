import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/get_all_requests_usecase.dart';
import 'package:lifelink/feature/home/presentation/state/home_state.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/get_all_organ_requests_usecase.dart';

/// Provider to access the HomeViewModel globally
/// This makes it easy for any screen to use the home logic
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(() => HomeViewModel());

/// ViewModel for home screen
/// This handles all the business logic: fetching requests, processing data,
/// and updating the UI state
class HomeViewModel extends Notifier<HomeState> {
  /// References to the use cases for fetching data
  /// These handle the actual API calls
  late final GetAllRequestsUsecase _getAllRequestsUsecase;
  late final GetAllOrganRequestsUsecase _getAllOrganRequestsUsecase;

  /// Initialize the ViewModel
  /// Sets up the use cases and returns empty initial state
  @override
  HomeState build() {
    // Get the use cases from Riverpod providers
    _getAllRequestsUsecase = ref.read(getAllRequestsUsecaseProvider);
    _getAllOrganRequestsUsecase = ref.read(getAllOrganRequestsUsecaseProvider);
    // Return empty state to start
    return const HomeState();
  }

  /// Get the current logged-in user ID
  /// First tries to get from auth, then from session storage
  /// Returns null if no user is logged in
  String? _currentUserId() {
    final authUserId = ref.read(authViewModelProvider).authEntity?.authId;
    final sessionUserId = ref.read(userSessionServiceProvider).getUserId();
    return authUserId ?? sessionUserId;
  }

  /// Convert status code to human-readable label
  /// Examples: 'approved' → 'Approved', 'rejected' → 'Rejected'
  String _statusLabel(String status) {
    if (status == 'approved') return 'Approved';
    if (status == 'rejected') return 'Rejected';
    return status;
  }

  /// Main method to load all requests from the API
  /// Simply fetches requests made by the logged-in donor
  Future<void> loadRequests() async {
    // Get current logged-in user
    final userId = _currentUserId();
    
    print('[HOME_VM] loadRequests called');
    print('  - userId: $userId');
    
    if (userId == null || userId.isEmpty) {
      print('[HOME_VM] No user logged in - showing empty state');
      // No user logged in, show empty state
      state = state.copyWith(
        status: HomeStatus.loaded,
        myRequests: const [],
        notifications: const [],
        errorMessage: 'Please log in to see your requests',
      );
      return;
    }

    // Set loading state
    print('[HOME_VM] Setting loading state...');
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);

    try {
      // Fetch BOTH blood and organ requests in PARALLEL with timeout
      print('[HOME_VM] Starting API calls...');
      
      final bloodFuture = _getAllRequestsUsecase(
        GetAllRequestsParams(requestedBy: userId),
      );
      
      final organFuture = _getAllOrganRequestsUsecase(
        GetAllOrganRequestsParams(requestedBy: userId),
      );

      // Execute both in parallel with timeout
      print('[HOME_VM] Waiting for API responses (25 second timeout)...');
      
      final bloodResult = await bloodFuture.timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          print('[HOME_VM] Blood request TIMEOUT after 25s');
          throw TimeoutException('Blood request timeout - backend not responding');
        },
      );
      print('[HOME_VM] Blood result received');
      
      final organResult = await organFuture.timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          print('[HOME_VM] Organ request TIMEOUT after 25s');
          throw TimeoutException('Organ request timeout - backend not responding');
        },
      );
      print('[HOME_VM] Organ result received');

      print('[HOME_VM] Both results obtained');

      // Variables to hold the results
      List<BloodRequestEntity> bloodRequests = [];
      List<OrganRequestEntity> organRequests = [];
      String? errorMessage;

      // Handle blood requests result (success or failure)
      print('[HOME_VM] Processing blood result...');
      bloodResult.fold(
        (failure) {
          print('[HOME_VM] Blood error: ${failure.message}');
          errorMessage = failure.message;
        },
        (requests) {
          print('[HOME_VM] Blood success: ${requests.length} requests');
          bloodRequests = requests;
        },
      );

      // Handle organ requests result (success or failure)
      print('[HOME_VM] Processing organ result...');
      organResult.fold(
        (failure) {
          print('[HOME_VM] Organ error: ${failure.message}');
          if (errorMessage == null) {
            errorMessage = failure.message;
          }
        },
        (requests) {
          print('[HOME_VM] Organ success: ${requests.length} requests');
          organRequests = requests;
        },
      );

      // Combine and transform data
      print('[HOME_VM] Building request items...');
      final myRequests = _buildMyRequests(bloodRequests, organRequests);
      final notifications = _buildNotifications(bloodRequests, organRequests);

      print('[HOME_VM] DONE! Total: ${myRequests.length} requests');
      
      // Update state with final data
      state = state.copyWith(
        status: HomeStatus.loaded,
        myRequests: myRequests,
        notifications: notifications,
        errorMessage: errorMessage,
      );
      print('[HOME_VM] State updated to LOADED, UI should refresh now');
    } on TimeoutException catch (e) {
      // Request took too long
      print('[HOME_VM] TIMEOUT ERROR: ${e.message}');
      state = state.copyWith(
        status: HomeStatus.error,
        myRequests: const [],
        notifications: const [],
        errorMessage: 'Backend not responding (timed out after 25s).\nCheck if server is running.',
      );
      print('[HOME_VM] State updated to ERROR');
    } catch (e, stackTrace) {
      // Handle all other errors
      print('[HOME_VM] UNEXPECTED ERROR: $e');
      print('  Type: ${e.runtimeType}');
      print('  Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      state = state.copyWith(
        status: HomeStatus.error,
        myRequests: const [],
        notifications: const [],
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
      print('[HOME_VM] State updated to ERROR');
    }
  }

  /// Convert blood and organ requests into displayable request items
  /// Shows all requests (pending, approved, rejected)
  List<HomeRequestItem> _buildMyRequests(
    List<BloodRequestEntity> bloodRequests,
    List<OrganRequestEntity> organRequests,
  ) {
    final List<HomeRequestItem> items = [];

    // Process each blood request
    for (final BloodRequestEntity request in bloodRequests) {
      // Show 'unit' or 'units' depending on quantity
      final unitsLabel = request.unitsRequested == 1 ? 'unit' : 'units';
      items.add(
        HomeRequestItem(
          id: 'blood-${request.id ?? request.createdAt.toString()}',
          title: 'Blood request',
          subtitle: '${request.bloodType} • ${request.unitsRequested} $unitsLabel',
          status: request.status,
          timestamp: request.updatedAt ?? request.createdAt,
        ),
      );
    }

    // Process each organ request
    for (final OrganRequestEntity request in organRequests) {
      items.add(
        HomeRequestItem(
          id: 'organ-${request.id ?? request.createdAt.toString()}',
          title: 'Organ request',
          subtitle: 'Donor: ${request.donorName}',
          status: request.status,
          timestamp: request.updatedAt ?? request.createdAt,
        ),
      );
    }

    // Sort by most recent first
    items.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return items;
  }

  /// Convert requests into notification items
  /// Only shows approved/rejected status updates (not pending)
  /// This is for the notifications popup
  List<HomeNotificationItem> _buildNotifications(
    List<BloodRequestEntity> bloodRequests,
    List<OrganRequestEntity> organRequests,
  ) {
    final List<HomeNotificationItem> items = [];

    // Process each blood request
    for (final BloodRequestEntity request in bloodRequests) {
      // Only show notifications for approved/rejected (not pending)
      if (request.status == 'approved' || request.status == 'rejected') {
        items.add(
          HomeNotificationItem(
            id: 'blood-${request.id ?? request.createdAt.toString()}',
            title: 'Blood request ${_statusLabel(request.status)}',
            message:
                '${request.hospitalName} ${request.status} your blood request for ${request.bloodType}',
            status: request.status,
            timestamp: request.updatedAt ?? request.createdAt,
          ),
        );
      }
    }

    // Process each organ request
    for (final OrganRequestEntity request in organRequests) {
      // Only show notifications for approved/rejected (not pending)
      if (request.status == 'approved' || request.status == 'rejected') {
        items.add(
          HomeNotificationItem(
            id: 'organ-${request.id ?? request.createdAt.toString()}',
            title: 'Organ request ${_statusLabel(request.status)}',
            message:
                '${request.hospitalName} ${request.status} your organ request',
            status: request.status,
            timestamp: request.updatedAt ?? request.createdAt,
          ),
        );
      }
    }

    // Sort by most recent first
    items.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return items;
  }
}
