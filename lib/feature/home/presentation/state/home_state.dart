import 'package:equatable/equatable.dart';

/// Enum to track the current state of home screen operations
/// - initial: First load, no data yet
/// - loading: Currently fetching data from server
/// - loaded: Data successfully received
/// - error: An error occurred while fetching
enum HomeStatus { initial, loading, loaded, error }

/// Main state class for Home screen
/// Holds all the data and status information needed to display the home UI
class HomeState extends Equatable {
  /// Current status of data loading (loading, loaded, error, etc.)
  final HomeStatus status;

  /// List of all user's requests (blood + organ)
  final List<HomeRequestItem> myRequests;

  /// List of notifications (approved/rejected status updates)
  final List<HomeNotificationItem> notifications;

  /// Error message if something goes wrong
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.myRequests = const [],
    this.notifications = const [],
    this.errorMessage,
  });

  /// Helper method to create a copy of this state with updated values
  /// Only the provided parameters are updated, others remain the same
  HomeState copyWith({
    HomeStatus? status,
    List<HomeRequestItem>? myRequests,
    List<HomeNotificationItem>? notifications,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      myRequests: myRequests ?? this.myRequests,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, myRequests, notifications, errorMessage];
}

/// Represents a single donation request (blood or organ)
/// Contains all display information needed to show in list
class HomeRequestItem extends Equatable {
  /// Unique identifier for this request
  final String id;

  /// Request type title (e.g., "Blood request" or "Organ request")
  final String title;

  /// Additional details (blood type + units, or donor name)
  final String subtitle;

  /// Current status (pending, approved, rejected, fulfilled)
  final String status;

  /// When the request was created or last updated
  final DateTime? timestamp;

  const HomeRequestItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, subtitle, status, timestamp];
}

/// Represents a notification about a request status change
/// Only shows approved/rejected updates (no pending notifications)
class HomeNotificationItem extends Equatable {
  /// Unique identifier for this notification
  final String id;

  /// Short notification title (e.g., "Blood request Approved")
  final String title;

  /// Full message text with details about the change
  final String message;

  /// Status that triggered this notification (approved or rejected)
  final String status;

  /// When this status change occurred
  final DateTime? timestamp;

  const HomeNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, message, status, timestamp];
}
