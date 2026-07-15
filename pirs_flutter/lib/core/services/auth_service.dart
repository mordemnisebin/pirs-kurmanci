import 'dart:convert';
import 'api_client.dart';
import 'api_config.dart';
import 'storage_service.dart';
import '../models/user.dart';

/// Karûbarê têketinê û qeydkirina bikarhêneran.
class AuthService {
  /// Bikarhênerê qeyd bike.
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final response =
          await ApiClient.post(
                '${ApiConfig.authEndpoint}/register',
                body: {
                  'email': email,
                  'password': password,
                  'nickname': nickname,
                },
              )
              as Map<String, dynamic>;

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveToken(token);
      await StorageService.saveUser(jsonEncode(userData));

      return AuthResult.success(
        token: token,
        user: UserProfile.fromJson(userData),
      );
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'Çewtiyek çêbû: ${e.toString()}');
    }
  }

  /// Bikarhênerê têxe.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await ApiClient.post(
                '${ApiConfig.authEndpoint}/login',
                body: {'email': email, 'password': password},
              )
              as Map<String, dynamic>;

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveToken(token);
      await StorageService.saveUser(jsonEncode(userData));

      return AuthResult.success(
        token: token,
        user: UserProfile.fromJson(userData),
      );
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'Çewtiyek çêbû: ${e.toString()}');
    }
  }

  /// Bikarhênerê niha bixwîne.
  static Future<UserProfile?> getCurrentUser() async {
    try {
      final response =
          await ApiClient.get('${ApiConfig.authEndpoint}/me')
              as Map<String, dynamic>;
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Derkeve (logout).
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  /// Bikarhênerê ji storage'ê bixwîne.
  static Future<UserProfile?> getStoredUser() async {
    final userJson = await StorageService.getUser();
    if (userJson != null) {
      return UserProfile.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}

/// Encama têketinê.
class AuthResult {
  AuthResult.success({required this.token, required this.user})
    : isSuccess = true,
      message = null;

  AuthResult.failure({required this.message})
    : isSuccess = false,
      token = null,
      user = null;

  final bool isSuccess;
  final String? token;
  final UserProfile? user;
  final String? message;
}
