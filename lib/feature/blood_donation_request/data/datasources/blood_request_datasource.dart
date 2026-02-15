import 'package:lifelink/feature/blood_donation_request/data/models/blood_request_api_model.dart';

abstract class IBloodRequestRemoteDataSource {
  Future<List<BloodRequestApiModel>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  });

  Future<BloodRequestApiModel> getRequestById(String id);

  Future<BloodRequestApiModel> createRequest(BloodRequestApiModel request);

  Future<BloodRequestApiModel> updateRequest(
      String id, BloodRequestApiModel request);

  Future<void> deleteRequest(String id);
}
