import 'dart:convert';
import 'api_client.dart';

class SessionService {
  final ApiClient _apiClient = ApiClient();

  /// Check-in hoặc Check-out bằng FaceID
  Future<Map<String, dynamic>> cicoByFace({
    required List<double> faceVector,
    int? age,
    String? gender,
  }) async {
    final response = await _apiClient.post(
      '/sessions/cico/face',
      body: {
        'faceVector': faceVector,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Face CICO failed: ${response.body}');
    }
  }

  /// Check-in hoặc Check-out bằng mã QR
  Future<Map<String, dynamic>> cicoByQRCode(String qrToken) async {
    final response = await _apiClient.post(
      '/sessions/cico/qr',
      body: {'qrToken': qrToken},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('QR CICO failed: ${response.body}');
    }
  }

  /// Force check-out bởi admin
  Future<Map<String, dynamic>> forceCheckOut(
    String sessionId,
    String reason,
  ) async {
    final response = await _apiClient.post(
      '/sessions/$sessionId/force-checkout',
      body: {'reason': reason},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Force check-out failed: ${response.body}');
    }
  }

  /// Lấy danh sách các lần sử dụng tử (sessions) của user hiện tại
  Future<Map<String, dynamic>> getMySessions({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    String endpoint = '/sessions/my-sessions?page=$page&limit=$limit';
    if (status != null && status.isNotEmpty) {
      endpoint += '&status=$status';
    }

    final response = await _apiClient.get(endpoint);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get my sessions: ${response.body}');
    }
  }

  /// Lấy tất cả các sessions đang active (Chỉ cho Admin)
  Future<Map<String, dynamic>> getActiveSessions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/sessions/active?page=$page&limit=$limit',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get active sessions: ${response.body}');
    }
  }
}
