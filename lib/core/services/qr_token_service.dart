import 'dart:convert';
import 'api_client.dart';

class QRTokenService {
  final ApiClient _apiClient = ApiClient();

  /// Create QR token for check-in/check-out
  Future<Map<String, dynamic>> generateQR() async {
    final response = await _apiClient.post('/qr-tokens/generate');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate QR token: ${response.body}');
    }
  }
}
