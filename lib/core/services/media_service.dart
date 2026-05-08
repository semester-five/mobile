import 'dart:convert';
import 'api_client.dart';

class MediaService {
  final ApiClient _apiClient = ApiClient();

  /// Upload file thông tin
  Future<Map<String, dynamic>> createMedia(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/media', body: data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create media: ${response.body}');
    }
  }

  /// Lấy Presigned URL để upload file (chẳng hạn như ảnh lên S3/MinIO)
  Future<Map<String, dynamic>> getPresignedUrl(
    String fileName,
    String bucket,
  ) async {
    final response = await _apiClient.get(
      '/media/presigned-url?fileName=$fileName&bucket=$bucket',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get presigned URL: ${response.body}');
    }
  }
}
