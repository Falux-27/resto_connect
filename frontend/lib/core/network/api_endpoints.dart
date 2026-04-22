abstract class ApiEndpoints {
  // ─── Base URL ──────────────────────────────────────────────
  // Android émulateur → 10.0.2.2 pointe vers localhost de la machine hôte
  // iOS simulateur   → localhost directement
  // Device physique  → IP locale de ta machine (ex: 192.168.1.X)
  static const String _devAndroid = 'http://10.0.2.2:8000';
  static const String _devIos     = 'http://localhost:8000';
  static const String _prod       = 'https://api.restoconnectdakar.com';

  // Changer ici pour cibler la bonne plateforme
  static const String baseUrl = _devAndroid;

  // ─── Endpoints ─────────────────────────────────────────────
  static const String chat        = '/chat';
  static const String search      = '/search';
  static const String restaurants = '/restaurants';
  static const String stats       = '/stats';
  static const String health      = '/';

  static String restaurantById(String id) => '/restaurants/$id';
}