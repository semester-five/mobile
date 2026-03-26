import 'dart:convert';
import 'dart:io';

import 'package:face_locker/features/auth/data/datasources/auth_exception.dart';
import 'package:face_locker/features/auth/data/models/login_form_dto.dart';
import 'package:face_locker/features/auth/data/models/register_form_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client, String? baseUrlOverride})
    : _client = client ?? http.Client(),
      _baseUrlOverride = baseUrlOverride;

  final http.Client _client;
  final String? _baseUrlOverride;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AuthRemoteDataSource] $message');
    }
  }

  void _logHttpSuccess({
    required String method,
    required Uri uri,
    required int statusCode,
  }) {
    _debugLog('$method $uri -> $statusCode');
  }

  void _logHttpError({
    required String method,
    required Uri uri,
    required int statusCode,
    required Map<String, dynamic> requestBody,
    required String responseBody,
  }) {
    _debugLog('$method $uri -> $statusCode (error)');
    _debugLog('Request body: $requestBody');
    _debugLog('Response body: $responseBody');
  }

  Future<void> login(LoginFormDto dto) async {
    const method = 'POST';
    final uri = Uri.parse('$_baseUrl/api/v1/auths/login');
    final requestBody = dto.toJson();
    final sanitizedRequestBody = Map<String, dynamic>.from(requestBody)
      ..update('password', (_) => '***', ifAbsent: () => '***');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logHttpSuccess(method: method, uri: uri, statusCode: response.statusCode);
      return;
    }

    _logHttpError(
      method: method,
      uri: uri,
      statusCode: response.statusCode,
      requestBody: sanitizedRequestBody,
      responseBody: response.body,
    );

    final errorMessage = _extractErrorMessage(response);
    _debugLog('Login API call failed: $errorMessage');
    throw AuthException(errorMessage);
  }

  Future<void> register(RegisterFormDto dto) async {
    const method = 'POST';
    final uri = Uri.parse('$_baseUrl/api/v1/auths/register');
    final requestBody = dto.toJson();
    final sanitizedRequestBody = Map<String, dynamic>.from(requestBody)
      ..update('password', (_) => '***', ifAbsent: () => '***');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logHttpSuccess(method: method, uri: uri, statusCode: response.statusCode);
      return;
    }

    _logHttpError(
      method: method,
      uri: uri,
      statusCode: response.statusCode,
      requestBody: sanitizedRequestBody,
      responseBody: response.body,
    );

    final errorMessage = _extractErrorMessage(response);
    _debugLog('Register API call failed: $errorMessage');
    throw AuthException(errorMessage);
  }

  String get _baseUrl {
    if (_baseUrlOverride != null && _baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
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
    } catch (_) {
      // Platform checks may fail in some test environments.
    }

    return 'localhost';
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore parse errors and return fallback message.
    }

    return 'Request failed with status code ${response.statusCode}';
  }
}
