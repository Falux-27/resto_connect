import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../local/restaurants_seed.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

/// Résultat d'un appel /chat
class ChatResult {
  final String reply;
  final List<RestaurantModel> restaurants;
  final String detectedLanguage;
  final bool fromCache;
  final double? totalTimeS;  // temps de réponse backend

  const ChatResult({
    required this.reply,
    required this.restaurants,
    required this.detectedLanguage,
    this.fromCache = false,
    this.totalTimeS,
  });
}

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._();
  factory ChatRepository() => _instance;
  ChatRepository._();

  final Dio _dio = ApiClient().dio;

  // ─── Historique de conversation (mémoire locale) ───────────
  final List<ChatMessageModel> _history = [];
  List<ChatMessageModel> get history => List.unmodifiable(_history);

  void clearHistory() => _history.clear();

  // ─── Appel principal /chat ─────────────────────────────────
  Future<ChatResult> sendMessage({
    required String message,
    double? userLat,
    double? userLng,
    String pipeline = 'fast',
  }) async {
    // Ajouter le message user à l'historique
    _history.add(ChatMessageModel(role: 'user', content: message));

    final body = {
      'message':              message,
      'pipeline':             pipeline,
      'conversation_history': _historyForApi(),
      if (userLat != null) 'user_lat': userLat,
      if (userLng != null) 'user_lng': userLng,
    };

    try {
      final response = await _dio.post(ApiEndpoints.chat, data: body);
      final data = response.data as Map<String, dynamic>;

      final reply = data['reply'] as String? ?? '';
      final lang  = data['detected_language'] as String? ?? 'fr';

      // Debug info du backend v4
      final debug = data['debug'] as Map<String, dynamic>?;
      final fromCache = debug?['from_cache'] as bool? ?? false;
      final totalTime = (debug?['total_time_s'] as num?)?.toDouble();

      // Parser les restaurants retournés par le backend
      final rawRestos = data['restaurants'] as List<dynamic>? ?? [];
      final restaurants = rawRestos
          .map((r) => _parseBackendRestaurant(r as Map<String, dynamic>))
          .toList();

      // Ajouter la réponse à l'historique
      _history.add(ChatMessageModel(role: 'assistant', content: reply));

      return ChatResult(
        reply:             reply,
        restaurants:       restaurants,
        detectedLanguage:  lang,
        fromCache:         fromCache,
        totalTimeS:        totalTime,
      );

    } on DioException catch (e) {
      // ─── Fallback offline ────────────────────────────────
      print('⚠️ [ChatRepo] API error: ${e.message}');
      final fallbackReply = _offlineFallback(message);
      _history.add(ChatMessageModel(role: 'assistant', content: fallbackReply));

      return ChatResult(
        reply:            fallbackReply,
        restaurants:      _localFallbackSearch(message),
        detectedLanguage: 'fr',
      );
    }
  }

  // ─── Recherche directe /search (sans chatbot) ──────────────
  Future<List<RestaurantModel>> search({
    double? userLat,
    double? userLng,
    int? budgetMaxFcfa,
    List<String>? dietary,
    List<String>? cuisineKeywords,
    String? textQuery,
    String? zone,
    String mode = 'balanced',
    int topN = 5,
  }) async {
    final body = {
      'mode':   mode,
      'top_n':  topN,
      if (userLat != null)          'user_lat':        userLat,
      if (userLng != null)          'user_lng':        userLng,
      if (budgetMaxFcfa != null)    'budget_max_fcfa': budgetMaxFcfa,
      if (dietary != null)          'dietary':         dietary,
      if (cuisineKeywords != null)  'cuisine_keywords': cuisineKeywords,
      if (textQuery != null)        'text_query':      textQuery,
      if (zone != null)             'zone':            zone,
    };

    try {
      final response = await _dio.post(ApiEndpoints.search, data: body);
      final list = response.data as List<dynamic>;
      return list.map((r) => _parseBackendRestaurant(r as Map<String, dynamic>)).toList();
    } on DioException {
      return _localFallbackSearch(textQuery ?? '');
    }
  }

  // ─── Parseur JSON → RestaurantModel ────────────────────────
  RestaurantModel _parseBackendRestaurant(Map<String, dynamic> r) {
    // Mapping price_range: backend envoie "low"/"mid"/"high"
    PriceRange pr;
    switch (r['price_range'] as String? ?? 'mid') {
      case 'low':   pr = PriceRange.cheap;     break;
      case 'high':  pr = PriceRange.expensive; break;
      default:      pr = PriceRange.mid;
    }

    // Merge tags + dietary + cuisine_type pour la compatibilité UI
    // Le backend envoie ces données séparément mais les helpers UI (isHalal, etc.)
    // vérifient tags.contains('halal')
    final baseTags = List<String>.from(r['tags'] ?? []);
    final dietary = List<String>.from(r['dietary'] ?? []);
    final cuisineType = List<String>.from(r['cuisine_type'] ?? []);
    final allTags = <String>{...baseTags, ...dietary, ...cuisineType}.toList();

    final menu = (r['menu'] as List<dynamic>? ?? [])
        .map((m) => MenuItemModel.fromJson(m as Map<String, dynamic>))
        .toList();

    // Construire le modèle
    final model = RestaurantModel(
      id:           r['id'] as String,
      name:         r['name'] as String,
      zone:         r['zone'] as String,
      lat:          (r['lat'] as num).toDouble(),
      lng:          (r['lng'] as num).toDouble(),
      priceRange:   pr,
      avgPrice:     (r['avg_price'] as num?)?.toInt() ?? 0,
      tags:         allTags,
      description:  r['description'] as String? ?? '',
      openingHours: r['opening_hours'] as String? ?? '',
      phone:        r['phone'] as String? ?? '',
      address:      r['zone'] as String? ?? '',
      imageUrl:     r['image'] as String? ?? '',
      rating:       (r['rating'] as num?)?.toDouble() ?? 4.0,
      menu:         menu,
    );

    // ── Distance ──
    model.distanceKm = (r['distance_km'] as num?)?.toDouble();

    // ── Match Score (FIX: parenthèses correctes) ──
    // Backend score est entre 0.0 et 1.0, on le convertit en 0-100
    final rawScore = (r['score'] as num?)?.toDouble() ?? 0.0;
    model.matchScore = (rawScore * 100).toInt();

    // ── Explanation → whyRecommended ──
    final exp = r['explanation'] as Map<String, dynamic>?;
    if (exp != null) {
      final reasons = <String>[];

      // Distance
      final distData = exp['distance'] as Map<String, dynamic>?;
      if (distData != null) {
        final km = (distData['km'] as num?)?.toDouble();
        if (km != null && km < 3) reasons.add('Proche');
        if (distData['boost'] == true) reasons.add('Juste à côté');
      }

      // Budget
      final budgetData = exp['budget'] as Map<String, dynamic>?;
      if (budgetData != null && (budgetData['score'] as num? ?? 0) >= 0.7) {
        reasons.add('Dans le budget');
      }

      // Text match
      final textData = exp['text_match'] as Map<String, dynamic>?;
      if (textData != null && (textData['score'] as num? ?? 0) > 0.5) {
        reasons.add('Match recherche');
      }

      // Rating
      final ratingData = exp['rating'] as Map<String, dynamic>?;
      if (ratingData != null && (ratingData['stars'] as num? ?? 0) >= 4.5) {
        reasons.add('Très bien noté');
      }

      model.whyRecommended = reasons;
    }

    // ── Plat signature ──
    for (final item in menu) {
      if (item.tags.contains('signature')) {
        model.recommendedDish = item.name;
        break;
      }
    }
    model.recommendedDish ??= menu.isNotEmpty ? menu.first.name : null;

    return model;
  }

  // ─── Historique pour l'API ─────────────────────────────────
  List<Map<String, dynamic>> _historyForApi() {
    final recent = _history.length > 6
        ? _history.sublist(_history.length - 6)
        : _history;
    return recent.map((m) => m.toJson()).toList();
  }

  // ─── Fallback offline ──────────────────────────────────────
  String _offlineFallback(String message) {
    return '⚠️ Je suis hors ligne pour l\'instant. '
        'Voici quelques suggestions depuis mes données locales.';
  }

  List<RestaurantModel> _localFallbackSearch(String query) {
    if (query.isEmpty) return restaurantsSeed.take(3).toList();
    final q = query.toLowerCase();
    return restaurantsSeed
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.tags.any((t) => t.contains(q)) ||
            r.menu.any((m) => m.name.toLowerCase().contains(q)))
        .take(3)
        .toList();
  }
}