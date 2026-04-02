import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/auth/data/datasources/auth_exception.dart';
import 'package:face_locker/features/auth/data/models/login_form_dto.dart';
import 'package:face_locker/features/auth/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[LoginController] $message');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) {
      _debugLog('Ignored login call because another request is in progress.');
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    _debugLog('Login request started.');

    try {
      final response = await _authRepository.login(LoginFormDto(email: email, password: password));
      UserService().setSession(response);
      _debugLog('Login request succeeded.');
      return true;
    } on AuthException catch (error, stackTrace) {
      _errorMessage = error.message;
      _debugLog('Login request failed: ${error.message}');
      _debugLog('Stack trace: $stackTrace');
      return false;
    } catch (error, stackTrace) {
      _errorMessage = 'Something went wrong. Please try again.';
      _debugLog('Unexpected login error: $error');
      _debugLog('Stack trace: $stackTrace');
      return false;
    } finally {
      _setLoading(false);
      _debugLog('Login request finished.');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
