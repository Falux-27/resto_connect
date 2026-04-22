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

  const ChatResult({
    required this.reply,
    required this.restaurants,
    required this.detectedLanguage,
    this.fromCache = false,
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
    String pipeline = 'fast',     // "fast" | "smart"
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
      final fromCache = (data['debug']?['from_cache'] as bool?) ?? false;

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
      );

    } on DioException catch (e) {
      // ─── Fallback offline ────────────────────────────────
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
    PriceRange pr;
    switch (r['price_range'] as String? ?? 'mid') {
      case 'low':   pr = PriceRange.cheap;     break;
      case 'high':  pr = PriceRange.expensive; break;
      default:      pr = PriceRange.mid;
    }

    final menu = (r['menu'] as List<dynamic>? ?? [])
        .map((m) => MenuItemModel.fromJson(m as Map<String, dynamic>))
        .toList();

    final model = RestaurantModel(
      id:           r['id'] as String,
      name:         r['name'] as String,
      zone:         r['zone'] as String,
      lat:          (r['lat'] as num).toDouble(),
      lng:          (r['lng'] as num).toDouble(),
      priceRange:   pr,
      avgPrice:     (r['avg_price'] as num?)?.toInt() ?? 0,
      tags:         List<String>.from(r['tags'] ?? []),
      description:  r['description'] as String? ?? '',
      openingHours: r['opening_hours'] as String? ?? '',
      phone:        r['phone'] as String? ?? '',
      address:      r['zone'] as String? ?? '',
      imageUrl:     r['image'] as String? ?? '',
      rating:       (r['rating'] as num?)?.toDouble() ?? 4.0,
      menu:         menu,
    );

    // Champs calculés retournés par le backend
    model.distanceKm   = (r['distance_km'] as num?)?.toDouble();
    model.matchScore   = ((r['score'] as num?)?.toDouble() ?? 0 * 100).toInt();

    // Explication → whyRecommended
    final exp = r['explanation'] as Map<String, dynamic>?;
    if (exp != null) {
      final reasons = <String>[];
      final distKm = (exp['distance'] as Map?)?['km'];
      if (distKm != null && (distKm as num) < 3) reasons.add('Proche');
      if ((exp['budget'] as Map?)?['score'] != null) reasons.add('Dans le budget');
      if (((exp['text_match'] as Map?)?['score'] as num? ?? 0) > 0) reasons.add('Match recherche');
      model.whyRecommended = reasons;
    }

    // Plat signature
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
    // On envoie max les 6 derniers messages (3 échanges)
    final recent = _history.length > 6
        ? _history.sublist(_history.length - 6)
        : _history;
    return recent.map((m) => m.toJson()).toList();
  }

  // ─── Fallback offline (seed locale) ────────────────────────
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