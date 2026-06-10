import 'dart:convert';

import 'api_client.dart';

class SessionService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> generateQRCodeToken() async {
    final response = await _apiClient.post('/qr-tokens/generate');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Generate QR token failed: ${response.body}');
    }
  }

  /// Check in or check out with Face ID.
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

  /// Check in or check out with a QR code.
  Future<Map<String, dynamic>> cicoByQRCode(String qrToken) async {
    final response = await _apiClient.post(
      '/sessions/cico/qr',
      body: {'qrToken': qrToken},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extractSessionError(response.body, 'QR CICO failed'));
    }
  }

  /// Force check-out by an admin.
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

  /// Get the current user's locker usage sessions.
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

  /// Get all active sessions. Admin only.
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

  String _extractSessionError(String responseBody, String fallback) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final code = decoded['code']?.toString();
        final message = decoded['message']?.toString();

        if (code == 'NO_AVAILABLE_LOCKER' ||
            message?.toLowerCase().contains('no available locker') == true) {
          return 'No available locker';
        }

        if (message != null && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Fall through to the short fallback below.
    }

    return fallback;
  }
}
