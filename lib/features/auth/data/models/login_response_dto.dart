import 'package:face_locker/features/auth/data/models/user_model.dart';

class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.refreshExpiresIn,
    required this.scope,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final int refreshExpiresIn;
  final String scope;
  final UserModel user;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final tokenData = json['token'] as Map<String, dynamic>?;
    final userData = json['user'] as Map<String, dynamic>?;

    return LoginResponseDto(
      accessToken: tokenData?['accessToken'] as String? ?? '',
      refreshToken: tokenData?['refreshToken'] as String? ?? '',
      expiresIn: tokenData?['expiresIn'] as int? ?? 0,
      tokenType: tokenData?['tokenType'] as String? ?? 'Bearer',
      refreshExpiresIn: tokenData?['refreshExpiresIn'] as int? ?? 0,
      scope: tokenData?['scope'] as String? ?? '',
      user: UserModel.fromJson(userData ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
        'tokenType': tokenType,
        'refreshExpiresIn': refreshExpiresIn,
        'scope': scope,
      },
      'user': user.toJson(),
    };
  }
}
