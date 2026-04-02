import 'package:face_locker/features/qrcode/data/datasources/qr_token_remote_datasource.dart';
import 'package:face_locker/features/qrcode/data/models/qr_token_response_dto.dart';

abstract class QrTokenRepository {
  Future<QrTokenResponseDto> generateQrToken({required String accessToken});
}

class QrTokenRepositoryImpl implements QrTokenRepository {
  QrTokenRepositoryImpl({required QrTokenRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QrTokenRemoteDataSource _remoteDataSource;

  @override
  Future<QrTokenResponseDto> generateQrToken({required String accessToken}) {
    return _remoteDataSource.generateQrToken(accessToken: accessToken);
  }
}
