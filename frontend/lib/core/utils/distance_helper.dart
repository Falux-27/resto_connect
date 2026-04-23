import 'dart:math';

/// Helpers pour le calcul et l'affichage des distances
class DistanceHelper {
  /// Calcule la distance en km entre deux points GPS (Haversine)
  static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _deg2rad(double d) => d * (pi / 180);

  /// Formate une distance pour l'affichage
  /// 0.05 km → "50 m"
  /// 0.8 km  → "800 m"
  /// 2.3 km  → "2.3 km"
  static String format(double km) {
    if (km < 0.1) return '${(km * 1000).round()} m';
    if (km < 1.0) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Estime le temps de marche (5 km/h)
  static String walkingTime(double km) {
    final minutes = (km / 5.0 * 60).round();
    if (minutes < 1) return '< 1 min';
    if (minutes < 60) return '$minutes min à pied';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h${mins > 0 ? '${mins.toString().padLeft(2, '0')}' : ''} à pied';
  }
}