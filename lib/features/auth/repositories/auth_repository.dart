import 'package:face_locker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:face_locker/features/auth/data/models/login_form_dto.dart';
import 'package:face_locker/features/auth/data/models/register_form_dto.dart';

abstract class AuthRepository {
  Future<void> login(LoginFormDto dto);
  Future<void> register(RegisterFormDto dto);
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> login(LoginFormDto dto) {
    return _remoteDataSource.login(dto);
  }

  @override
  Future<void> register(RegisterFormDto dto) {
    return _remoteDataSource.register(dto);
  }
}
