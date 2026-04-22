import 'menu_item_model.dart';

/// price_range enum
enum PriceRange { cheap, mid, expensive }

extension PriceRangeExt on PriceRange {
  String get label {
    switch (this) {
      case PriceRange.cheap:     return 'Petit budget';
      case PriceRange.mid:       return 'Prix moyen';
      case PriceRange.expensive: return 'Gastronomique';
    }
  }

  String get fcfaRange {
    switch (this) {
      case PriceRange.cheap:     return '< 5 000 FCFA';
      case PriceRange.mid:       return '5 000 – 15 000 FCFA';
      case PriceRange.expensive: return '> 15 000 FCFA';
    }
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String zone;
  final double lat;
  final double lng;
  final PriceRange priceRange;
  final int avgPrice;
  final List<String> tags;
  final String description;
  final String openingHours;
  final String phone;
  final String address;
  final List<MenuItemModel> menu;
  final String imageUrl;
  final double rating;

  // ─── Champs calculés au runtime ────────────────────────────
  /// Distance depuis la position de l'utilisateur (km)
  double? distanceKm;

  /// Score de matching IA (0–100), calculé par le chatbot
  int? matchScore;

  /// Plat recommandé par l'IA pour cette recherche
  String? recommendedDish;

  /// Raisons de recommandation : ['Proche', 'Dans le budget', 'Match recherche']
  List<String> whyRecommended;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.zone,
    required this.lat,
    required this.lng,
    required this.priceRange,
    required this.avgPrice,
    required this.tags,
    required this.description,
    required this.openingHours,
    required this.phone,
    required this.address,
    required this.menu,
    required this.imageUrl,
    this.rating = 4.5,
    this.distanceKm,
    this.matchScore,
    this.recommendedDish,
    this.whyRecommended = const [],
  });

  // ─── Helpers ───────────────────────────────────────────────
  bool get isHalal      => tags.contains('halal');
  bool get isVegetarian => tags.contains('vegetarien') || tags.contains('vegan');
  bool get hasSeaView   => tags.contains('vue mer');
  bool get isCheap      => priceRange == PriceRange.cheap;

  String get priceDisplay {
    if (menu.isEmpty) return '$avgPrice FCFA';
    final prices = menu.map((m) => m.price).toList()..sort();
    return '${_fmt(prices.first)} – ${_fmt(prices.last)} FCFA';
  }

  String _fmt(int v) {
    // 3500 → "3 500"
    return v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }

  String get distanceLabel {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  // ─── Serialization ─────────────────────────────────────────
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    PriceRange pr;
    switch (json['price_range']) {
      case 'cheap':     pr = PriceRange.cheap; break;
      case 'expensive': pr = PriceRange.expensive; break;
      default:          pr = PriceRange.mid;
    }
    return RestaurantModel(
      id:           json['id'] as String,
      name:         json['name'] as String,
      zone:         json['zone'] as String,
      lat:          (json['lat'] as num).toDouble(),
      lng:          (json['lng'] as num).toDouble(),
      priceRange:   pr,
      avgPrice:     json['avg_price'] as int,
      tags:         List<String>.from(json['tags'] ?? []),
      description:  json['description'] as String? ?? '',
      openingHours: json['opening_hours'] as String? ?? '',
      phone:        json['phone'] as String? ?? '',
      address:      json['address'] as String? ?? '',
      imageUrl:     json['image'] as String? ?? '',
      rating:       (json['rating'] as num?)?.toDouble() ?? 4.5,
      menu: (json['menu'] as List<dynamic>? ?? [])
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':           id,
        'name':         name,
        'zone':         zone,
        'lat':          lat,
        'lng':          lng,
        'price_range':  priceRange.name,
        'avg_price':    avgPrice,
        'tags':         tags,
        'description':  description,
        'opening_hours': openingHours,
        'phone':        phone,
        'address':      address,
        'image':        imageUrl,
        'rating':       rating,
        'menu':         menu.map((m) => m.toJson()).toList(),
      };
}