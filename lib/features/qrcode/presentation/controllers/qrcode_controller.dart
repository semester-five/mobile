import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/qrcode/data/datasources/qr_token_remote_datasource.dart';
import 'package:face_locker/features/qrcode/data/models/qr_token_response_dto.dart';
import 'package:face_locker/features/qrcode/repository/qr_token_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class QrcodeController extends ChangeNotifier {
  QrcodeController({QrTokenRepository? qrTokenRepository, UserService? userService})
    : _qrTokenRepository = qrTokenRepository ??
          QrTokenRepositoryImpl(remoteDataSource: QrTokenRemoteDataSource()),
      _userService = userService ?? UserService();

  final QrTokenRepository _qrTokenRepository;
  final UserService _userService;

  bool _isLoading = false;
  String? _errorMessage;
  QrTokenResponseDto? _qrTokenResponse;
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  QrTokenResponseDto? get qrTokenResponse => _qrTokenResponse;
  int get remainingSeconds => _remainingSeconds;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[QrcodeController] $message');
    }
  }

  Future<void> loadQrToken() async {
    if (_isLoading) {
      _debugLog('Ignored QR load because another request is in progress.');
      return;
    }

    final accessToken = _userService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _errorMessage = 'No access token found. Please login again.';
      notifyListeners();
      return;
    }

    if (_userService.isAccessTokenExpired) {
      _errorMessage = _userService.canRefreshSession
          ? 'Access token expired. Please login again to refresh the session.'
          : 'Access token expired. Please login again.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;
    _debugLog('QR token request started.');

    try {
      _qrTokenResponse = await _qrTokenRepository.generateQrToken(accessToken: accessToken);
      _startTimers(_qrTokenResponse?.expiresInSeconds ?? 300);
      _debugLog('QR token request succeeded.');
    } catch (error, stackTrace) {
      _errorMessage = 'Failed to generate QR code. Please try again.';
      _debugLog('QR token request failed: $error');
      _debugLog('Stack trace: $stackTrace');
    } finally {
      _setLoading(false);
      _debugLog('QR token request finished.');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _startTimers(int expiresInSeconds) {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();

    _remainingSeconds = expiresInSeconds;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }

      _remainingSeconds -= 1;
      notifyListeners();
    });

    _refreshTimer = Timer(Duration(seconds: expiresInSeconds), () async {
      await loadQrToken();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
