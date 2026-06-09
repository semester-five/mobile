import 'dart:convert';
import 'dart:io';

import 'package:face_locker/core/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String get baseUrl {
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl != null && apiUrl.isNotEmpty) {
      return apiUrl;
    }

    final host = dotenv.env['API_HOST'] ?? _defaultHost;
    final port = dotenv.env['PORT'] ?? '3000';
    final prefix = dotenv.env['API_PREFIX'] ?? '/api/v1';
    return 'http://$host:$port$prefix';
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedToken = prefs.getString('access_token');
    final sessionToken = UserService().accessToken;
    final token = cachedToken ?? sessionToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String get _defaultHost {
    if (kIsWeb) {
      return 'localhost';
    }

    try {
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }

      if (Platform.isIOS) {
        return 'localhost';
      }
    } catch (_) {}

    return 'localhost';
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
