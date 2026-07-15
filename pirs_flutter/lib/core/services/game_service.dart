import 'api_client.dart';
import 'api_config.dart';

/// Karûbarê lîstikê.
class GameService {
  /// Lîstikê biqedîne û encamê tomar bike.
  static Future<Map<String, dynamic>> finishGame({
    required int score,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.gamesEndpoint}/finish',
        body: {
          'score': score,
          'totalQuestions': totalQuestions,
          'correctAnswers': correctAnswers,
        },
      ) as Map<String, dynamic>;

      return response;
    } catch (e) {
      throw Exception('Encam nehat tomarkirin: ${e.toString()}');
    }
  }

  /// Statisîkên bikarhênerê bistîne.
  static Future<GameStats> getStats() async {
    try {
      final response = await ApiClient.get(
        '${ApiConfig.gamesEndpoint}/stats',
      ) as Map<String, dynamic>;
      return GameStats.fromJson(response);
    } catch (e) {
      throw Exception('Statisîk nehatin girtin: ${e.toString()}');
    }
  }
}

class GameStats {
  GameStats({
    required this.totalSessions,
    required this.bestScore,
    required this.averageScore,
    required this.correctRate,
  });

  final int totalSessions;
  final int bestScore;
  final int averageScore;
  final double correctRate;

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalSessions: json['totalSessions'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      averageScore: json['averageScore'] as int? ?? 0,
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0,
    );
  }
}
