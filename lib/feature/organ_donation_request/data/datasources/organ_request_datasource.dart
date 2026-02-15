import 'dart:io';
import 'package:lifelink/feature/organ_donation_request/data/models/organ_request_api_model.dart';

abstract class IOrganRequestRemoteDataSource {
  Future<OrganRequestApiModel> createRequest({
    required OrganRequestApiModel request,
    required File reportFile,
  });

  Future<List<OrganRequestApiModel>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  });

  Future<OrganRequestApiModel> getRequestById(String id);

  Future<OrganRequestApiModel> updateRequest(
    String id,
    OrganRequestApiModel request,
    {File? reportFile}
  );

  Future<void> deleteRequest(String id);
}
