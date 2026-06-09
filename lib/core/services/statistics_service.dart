import 'dart:convert';

import 'api_client.dart';

class StatisticsService {
  final ApiClient _apiClient = ApiClient();

  Future<GuestDemographicsStatsPage> getGuestDemographics({
    required DateTime dateFrom,
    required DateTime dateTo,
    int pageNumber = 1,
    int pageSize = 100,
    String? lockerId,
  }) async {
    final params = <String, String>{
      'dateFrom': dateFrom.toUtc().toIso8601String(),
      'dateTo': dateTo.toUtc().toIso8601String(),
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (lockerId != null && lockerId.trim().isNotEmpty)
        'lockerId': lockerId.trim(),
    };

    final query = Uri(queryParameters: params).query;
    final response = await _apiClient.get(
      '/statistics/guests/demographics?$query',
    );

    if (response.statusCode == 200) {
      return GuestDemographicsStatsPage.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to load guest demographics: ${response.statusCode} - ${response.body}',
    );
  }
}

class GuestDemographicsStatsPage {
  const GuestDemographicsStatsPage({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  final List<GuestDemographicsStats> data;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  int get totalSessions {
    return data.fold(0, (sum, item) => sum + item.totalSessions);
  }

  int get maleCount {
    return data.fold(0, (sum, item) => sum + item.maleCount);
  }

  int get femaleCount {
    return data.fold(0, (sum, item) => sum + item.femaleCount);
  }

  int get unknownCount {
    return data.fold(0, (sum, item) => sum + item.unknownCount);
  }

  factory GuestDemographicsStatsPage.fromJson(Map<String, dynamic> json) {
    final items = json['data'];
    return GuestDemographicsStatsPage(
      data: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(GuestDemographicsStats.fromJson)
                .toList(growable: false)
          : const [],
      pageNumber: _readInt(json['pageNumber']),
      pageSize: _readInt(json['pageSize']),
      totalRecords: _readInt(json['totalRecords']),
      totalPages: _readInt(json['totalPages']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class GuestDemographicsStats {
  const GuestDemographicsStats({
    required this.ageGroup,
    required this.maleCount,
    required this.femaleCount,
    required this.unknownCount,
    required this.totalSessions,
  });

  final String ageGroup;
  final int maleCount;
  final int femaleCount;
  final int unknownCount;
  final int totalSessions;

  factory GuestDemographicsStats.fromJson(Map<String, dynamic> json) {
    return GuestDemographicsStats(
      ageGroup: json['ageGroup']?.toString() ?? 'UNKNOWN',
      maleCount: GuestDemographicsStatsPage._readInt(json['maleCount']),
      femaleCount: GuestDemographicsStatsPage._readInt(json['femaleCount']),
      unknownCount: GuestDemographicsStatsPage._readInt(json['unknownCount']),
      totalSessions: GuestDemographicsStatsPage._readInt(json['totalSessions']),
    );
  }
}
