import 'api_client.dart';
import 'api_config.dart';
import '../models/question.dart';

/// Karûbarê pirsan.
class QuestionService {
  /// Pirsan bixwîne.
  static Future<List<Question>> getQuestions({
    String? categoryId,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (categoryId != null) 'categoryId': categoryId,
      };

      final response = await ApiClient.get(
        ApiConfig.questionsEndpoint,
        queryParams: queryParams,
      );

      // Backend array döndürüyor
      List<dynamic> questionsList;
      if (response is List) {
        questionsList = response;
      } else if (response is Map && response.containsKey('data')) {
        questionsList = response['data'] as List<dynamic>;
      } else {
        questionsList = [response];
      }

      return questionsList
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Pirsan nehatin girtin: ${e.toString()}');
    }
  }
}
