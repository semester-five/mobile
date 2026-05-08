import 'dart:convert';
import 'api_client.dart';

class LockerService {
  final ApiClient _apiClient = ApiClient();

  /// Create a new locker (Admin)
  Future<void> createLocker(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/lockers', body: data);
    if (response.statusCode != 201) {
      throw Exception('Failed to create locker: ${response.body}');
    }
  }

  /// Get all lockers with pagination and filters
  Future<Map<String, dynamic>> getAllLockers({
    int pageNumber = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) async {
    final body = {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (filters != null) ...filters,
    };

    final response = await _apiClient.post('/lockers/filters', body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load lockers: ${response.body}');
    }
  }

  /// Get locker by ID
  Future<Map<String, dynamic>> getLockerById(String id) async {
    final response = await _apiClient.get('/lockers/$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load locker: ${response.body}');
    }
  }

  /// Update a locker
  Future<void> updateLocker(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/lockers/$id', body: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to update locker: ${response.body}');
    }
  }

  /// Update locker status and door state
  Future<void> updateLockerState(
    String id,
    String status,
    String doorState,
  ) async {
    final response = await _apiClient.patch(
      '/lockers/$id/state',
      body: {'status': status, 'doorState': doorState},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update locker state: ${response.body}');
    }
  }

  /// Delete a locker
  Future<void> deleteLocker(String id) async {
    final response = await _apiClient.delete('/lockers/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete locker: ${response.body}');
    }
  }
}
