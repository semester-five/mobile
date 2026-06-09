import 'package:face_locker/features/auth/data/models/login_response_dto.dart';
import 'package:face_locker/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  LoginResponseDto? _session;

  LoginResponseDto? get session => _session;
  UserModel? get currentUser => _session?.user;
  String? get accessToken => _session?.accessToken;
  String? get refreshToken => _session?.refreshToken;
  String get tokenType => _session?.tokenType ?? 'Bearer';
  DateTime? get accessTokenExpiresAt {
    final session = _session;
    return session?.issuedAt.add(Duration(seconds: session.expiresIn));
  }

  bool get isLoggedIn => _session != null;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isUser => currentUser?.isUser ?? false;
  bool get canRefreshSession =>
      refreshToken != null && refreshToken!.isNotEmpty;
  bool get isAccessTokenExpired {
    final expiresAt = accessTokenExpiresAt;
    if (expiresAt == null) {
      return true;
    }
    return DateTime.now().isAfter(expiresAt);
  }

  void setSession(LoginResponseDto session) {
    _session = session;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    if (_session == null) {
      return;
    }
    _session = LoginResponseDto(
      accessToken: _session!.accessToken,
      refreshToken: _session!.refreshToken,
      expiresIn: _session!.expiresIn,
      tokenType: _session!.tokenType,
      refreshExpiresIn: _session!.refreshExpiresIn,
      scope: _session!.scope,
      user: user,
      issuedAt: _session!.issuedAt,
    );
    notifyListeners();
  }
}
