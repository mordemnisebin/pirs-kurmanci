import 'api_client.dart';
import 'api_config.dart';

/// Karûbarê tabloya giştî.
class LeaderboardService {
  /// Tabloya giştî bixwîne.
  static Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'allTime',
  }) async {
    try {
      final response = await ApiClient.get(
        ApiConfig.leaderboardEndpoint,
        queryParams: {'period': period},
      );

      // Backend array döndürüyor
      List<dynamic> entriesList;
      if (response is List) {
        entriesList = response;
      } else if (response is Map && response.containsKey('data')) {
        entriesList = response['data'] as List<dynamic>;
      } else {
        entriesList = [response];
      }

      return entriesList
          .map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Tabloya giştî nehat girtin: ${e.toString()}');
    }
  }
}

/// Encama tabloya giştî.
class LeaderboardEntry {
  LeaderboardEntry({
    required this.userId,
    required this.nickname,
    required this.score,
    required this.createdAt,
  });

  final String userId;
  final String nickname;
  final int score;
  final DateTime createdAt;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      score: json['score'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
