import 'api_client.dart';
import 'api_config.dart';
import '../models/category.dart';

/// Karûbarê kategoriyan.
class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await ApiClient.get(ApiConfig.categoriesEndpoint);

      List<dynamic> list;
      if (response is List) {
        list = response;
      } else if (response is Map && response.containsKey('data')) {
        list = response['data'] as List<dynamic>;
      } else {
        list = [response];
      }

      return list
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Kategorî nehatin girtin: ${e.toString()}');
    }
  }
}
