import 'dart:convert';

import 'api_client.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getNotificationsByUserId(
    String userId, {
    List<String> channels = const [],
  }) async {
    final query = _buildChannelsQuery(channels);
    final response = await _apiClient.get('/notifications/$userId$query');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return _extractItems(decoded);
    }

    throw Exception('Failed to load notifications: ${response.body}');
  }

  String _buildChannelsQuery(List<String> channels) {
    final normalizedChannels = channels
        .map((channel) => channel.trim())
        .where((channel) => channel.isNotEmpty)
        .toList();

    if (normalizedChannels.isEmpty) return '';

    // Nest maps repeated query params to string[], while a single
    // ?channels=mobile is received as a String and the backend treats it as
    // iterable chars.
    final queryChannels = normalizedChannels.length == 1
        ? [normalizedChannels.first, normalizedChannels.first]
        : normalizedChannels;
    final query = queryChannels
        .map((channel) => 'channels=${Uri.encodeQueryComponent(channel)}')
        .join('&');

    return '?$query';
  }

  List<Map<String, dynamic>> _extractItems(dynamic payload) {
    final candidates = <dynamic>[
      if (payload is Map<String, dynamic>) ...[
        payload['data'],
        payload['items'],
        payload['notifications'],
        payload['content'],
      ],
      payload,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }
}
