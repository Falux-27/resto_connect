import 'dart:math';
import '../models/restaurant_model.dart';
import '../local/restaurants_seed.dart';

class RestaurantRepository {
  // Singleton léger
  static final RestaurantRepository _instance = RestaurantRepository._();
  factory RestaurantRepository() => _instance;
  RestaurantRepository._();

  // Source de données (seed locale pour l'instant, remplaçable par API)
  final List<RestaurantModel> _all = restaurantsSeed;

  // ─── Tous les restos ───────────────────────────────────────
  List<RestaurantModel> getAll() => List.from(_all);

  // ─── Par ID ────────────────────────────────────────────────
  RestaurantModel? getById(String id) {
    try {
      return _all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Recherche textuelle simple ────────────────────────────
  /// Filtre par query + tags actifs + calcule la distance
  List<RestaurantModel> search({
    required String query,
    List<String> activeTags = const [],
    double? userLat,
    double? userLng,
  }) {
    final q = query.toLowerCase().trim();

    var results = _all.where((r) {
      // Match query dans nom, zone, description, tags, plats
      final inName  = r.name.toLowerCase().contains(q);
      final inZone  = r.zone.toLowerCase().contains(q);
      final inDesc  = r.description.toLowerCase().contains(q);
      final inTags  = r.tags.any((t) => t.toLowerCase().contains(q));
      final inMenu  = r.menu.any((m) => m.name.toLowerCase().contains(q));
      final textMatch = q.isEmpty || inName || inZone || inDesc || inTags || inMenu;

      // Filtres rapides actifs
      bool tagMatch = true;
      for (final tag in activeTags) {
        if (!r.tags.contains(tag)) { tagMatch = false; break; }
      }

      return textMatch && tagMatch;
    }).toList();

    // Calcul des distances si position disponible
    if (userLat != null && userLng != null) {
      for (final r in results) {
        r.distanceKm = _haversineKm(userLat, userLng, r.lat, r.lng);
      }
      results.sort((a, b) =>
          (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    }

    // Score de matching basique (sera enrichi par l'IA)
    for (final r in results) {
      r.matchScore = _computeBasicScore(r, q);
      r.whyRecommended = _buildWhyRecommended(r, q);
      // Plat recommandé = premier plat dont le nom match la query
      final dish = r.menu.firstWhere(
        (m) => m.name.toLowerCase().contains(q) || m.tags.any((t) => t.contains(q)),
        orElse: () => r.menu.first,
      );
      r.recommendedDish = dish.name;
    }

    return results;
  }

  // ─── Filtre rapide par tag ─────────────────────────────────
  List<RestaurantModel> filterByTag(String tag) {
    return _all.where((r) => r.tags.contains(tag)).toList();
  }

  // ─── Helpers privés ────────────────────────────────────────
  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double d) => d * (pi / 180);

  int _computeBasicScore(RestaurantModel r, String q) {
    int score = 60;
    if (r.name.toLowerCase().contains(q))  score += 20;
    if (r.tags.any((t) => t.contains(q)))  score += 10;
    if (r.menu.any((m) => m.name.toLowerCase().contains(q))) score += 10;
    if (r.distanceKm != null && r.distanceKm! < 2) score += 5;
    return score.clamp(0, 100);
  }

  List<String> _buildWhyRecommended(RestaurantModel r, String q) {
    final reasons = <String>[];
    if (r.distanceKm != null && r.distanceKm! < 3) reasons.add('Proche');
    if (r.priceRange == PriceRange.cheap) reasons.add('Dans le budget');
    if (r.menu.any((m) => m.name.toLowerCase().contains(q))) {
      reasons.add('Match recherche');
    }
    return reasons;
  }
}