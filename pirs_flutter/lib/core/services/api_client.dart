import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

/// Mijarê API clientê yekgirtî.
class ApiClient {
  /// GET request.
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
    );

    return _handleResponse(response);
  }

  /// POST request.
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Response'ê kontrol bike û parse bike.
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(response.body);
      // Array veya Map dönebilir
      return decoded;
    } else {
      final errorBody = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] as String? ?? 'Çewtiyek çêbû',
      );
    }
  }
}

/// Çewtiya API.
class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
