import 'package:flutter/foundation.dart';

/// Mîhengên API.
class ApiConfig {
  // Production URL - Render.com
  static const String _productionUrl = 'https://pirs-backend.onrender.com';

  // Development URL
  static const String _developmentUrl = 'http://localhost:4000';

  // Otomatik URL seçimi
  static String get baseUrl {
    if (kReleaseMode) {
      return _productionUrl;
    }
    // Web'de çalışıyorsa localhost, değilse emulator için 10.0.2.2
    if (kIsWeb) {
      return _developmentUrl;
    }
    return 'http://10.0.2.2:4000';
  }

  static const String authEndpoint = '/auth';
  static const String categoriesEndpoint = '/categories';
  static const String questionsEndpoint = '/questions';
  static const String gamesEndpoint = '/games';
  static const String leaderboardEndpoint = '/leaderboard';
}
