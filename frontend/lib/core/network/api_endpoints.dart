import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiEndpoints {
  // ─── Base URL (auto-détection) ─────────────────────────────
  // En debug: détecte Android émulateur vs iOS vs device physique
  // En release: utilise la variable d'env BASE_URL ou le fallback prod

  static String get baseUrl {
    // 1. Si défini dans .env → priorité absolue
    final envUrl = dotenv.env['BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // 2. En mode debug → localhost selon la plateforme
    if (kDebugMode) {
      if (kIsWeb) return 'http://localhost:8000';
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      if (Platform.isIOS) return 'http://localhost:8000';
      // Windows/Linux/macOS desktop
      return 'http://localhost:8000';
    }

    // 3. Production
    return 'https://api.restoconnectdakar.com';
  }

  // ─── Endpoints ─────────────────────────────────────────────
  static const String chat        = '/chat';
  static const String search      = '/search';
  static const String restaurants = '/restaurants';
  static const String stats       = '/stats';
  static const String health      = '/';

  static String restaurantById(String id) => '/restaurants/$id';
}