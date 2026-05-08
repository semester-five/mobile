import 'dart:convert';

import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/auth/data/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Đăng ký người dùng mới
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/auths/register', body: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  /// Đăng nhập bằng Email / Mật khẩu
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auths/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword(Map<String, dynamic> data) async {
    final response = await _apiClient.put('/auths/change-password', body: data);
    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  /// Khởi tạo phiên đăng nhập Google
  Future<Map<String, dynamic>> googleLogin(String googleToken) async {
    final response = await _apiClient.post(
      '/auths/google',
      body: {
        'token': googleToken, // tuỳ chỉnh key theo DTO của backend
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
      return data;
    } else {
      throw Exception('Google login failed: ${response.body}');
    }
  }

  /// Khởi tạo phiên đăng nhập Apple
  Future<Map<String, dynamic>> appleLogin(String appleToken) async {
    final response = await _apiClient.post(
      '/auths/apple',
      body: {'token': appleToken},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
      return data;
    } else {
      throw Exception('Apple login failed: ${response.body}');
    }
  }

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken(String rToken) async {
    final response = await _apiClient.post(
      '/auths/refresh-token',
      body: {'refreshToken': rToken},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
      return data;
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  /// Lấy thông tin user hiện tại
  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.get('/auths/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get current user info: ${response.body}');
    }
  }

  /// Cập nhật thông tin hồ sơ
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final endpoint =
        dotenv.env['PROFILE_UPDATE_ENDPOINT']?.trim().isNotEmpty == true
        ? dotenv.env['PROFILE_UPDATE_ENDPOINT']!.trim()
        : '/users/update-profile';
    final method = (dotenv.env['PROFILE_UPDATE_METHOD'] ?? 'PUT')
        .trim()
        .toUpperCase();

    var response = await _sendProfileUpdate(endpoint, data, method);

    if (response.statusCode == 405 && method != 'PUT') {
      response = await _sendProfileUpdate(endpoint, data, 'PUT');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        final me = await getMe();
        final meData = me['data'];
        final userJson = meData is Map<String, dynamic> ? meData : me;
        return UserModel.fromJson(userJson);
      }

      final payload = jsonDecode(response.body);
      if (payload is Map<String, dynamic>) {
        final dataField = payload['data'];
        final userField = payload['user'];
        final rawUserJson = dataField is Map<String, dynamic>
            ? dataField
            : userField is Map<String, dynamic>
            ? userField
            : payload;

        return _mergeWithCurrentUser(rawUserJson);
      }
    }

    throw Exception('Failed to update profile: ${response.body}');
  }

  Future<dynamic> _sendProfileUpdate(
    String endpoint,
    Map<String, dynamic> data,
    String method,
  ) {
    switch (method) {
      case 'PUT':
        return _apiClient.put(endpoint, body: data);
      default:
        return _apiClient.patch(endpoint, body: data);
    }
  }

  UserModel _mergeWithCurrentUser(Map<String, dynamic> userJson) {
    final currentUser = UserService().currentUser;

    if (currentUser == null) {
      return UserModel.fromJson(userJson);
    }

    final merged = {...currentUser.toJson(), ...userJson};

    return UserModel.fromJson(merged);
  }

  /// Lưu token xuống máy
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenMap = data['token'] is Map<String, dynamic>
        ? data['token'] as Map<String, dynamic>
        : data;

    if (tokenMap.containsKey('accessToken')) {
      await prefs.setString('access_token', tokenMap['accessToken']);
    }
    if (tokenMap.containsKey('refreshToken')) {
      await prefs.setString('refresh_token', tokenMap['refreshToken']);
    }
  }

  /// Xoá token (Đăng xuất)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
