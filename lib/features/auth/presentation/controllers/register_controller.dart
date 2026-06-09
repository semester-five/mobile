import 'package:face_locker/features/auth/data/datasources/auth_exception.dart';
import 'package:face_locker/features/auth/data/models/register_form_dto.dart';
import 'package:face_locker/features/auth/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[RegisterController] $message');
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String birthday,
    required String phoneNumber,
    required String password,
  }) async {
    if (_isLoading) {
      _debugLog(
        'Ignored register call because another request is in progress.',
      );
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    _debugLog('Register request started.');

    try {
      await _authRepository.register(
        RegisterFormDto(
          firstName: firstName,
          lastName: lastName,
          email: email,
          gender: gender,
          birthday: birthday,
          phoneNumber: phoneNumber,
          password: password,
        ),
      );

      _debugLog('Register request succeeded.');
      return true;
    } on AuthException catch (error, stackTrace) {
      _errorMessage = error.message;
      _debugLog('Register request failed: ${error.message}');
      _debugLog('Stack trace: $stackTrace');
      return false;
    } catch (error, stackTrace) {
      _errorMessage = 'Something went wrong. Please try again.';
      _debugLog('Unexpected register error: $error');
      _debugLog('Stack trace: $stackTrace');
      return false;
    } finally {
      _setLoading(false);
      _debugLog('Register request finished.');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
