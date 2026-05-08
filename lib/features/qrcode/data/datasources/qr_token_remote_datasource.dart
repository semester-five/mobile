import 'dart:convert';

import 'dart:io';

import 'package:face_locker/features/qrcode/data/models/qr_token_response_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class QrTokenRemoteDataSource {
  QrTokenRemoteDataSource({http.Client? client, String? baseUrlOverride})
    : _client = client ?? http.Client(),
      _baseUrlOverride = baseUrlOverride;

  final http.Client _client;
  final String? _baseUrlOverride;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[QrTokenRemoteDataSource] $message');
    }
  }

  Future<QrTokenResponseDto> generateQrToken({
    required String accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/qr-tokens/generate');

    final response = await _client.post(
      uri,
      headers: {'Accept': '*/*', 'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _debugLog('POST $uri -> ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return QrTokenResponseDto.fromJson(data);
    }

    _debugLog('POST $uri -> ${response.statusCode} (error)');
    _debugLog('Response body: ${response.body}');
    throw Exception('Failed to generate QR token (${response.statusCode})');
  }

  String get _baseUrl {
    final override = _baseUrlOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }

    final host = dotenv.env['API_HOST'] ?? _defaultHost;
    final port = dotenv.env['PORT'] ?? '3000';
    return 'http://$host:$port';
  }

  String get _defaultHost {
    if (kIsWeb) {
      return 'localhost';
    }

    try {
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }

      if (Platform.isIOS) {
        return '192.168.1.2';
      }
    } catch (_) {}

    return 'localhost';
  }
}
