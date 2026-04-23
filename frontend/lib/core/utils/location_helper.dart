import 'package:geolocator/geolocator.dart';

/// Helper pour la géolocalisation
class LocationHelper {
  /// Demande la permission et retourne la position GPS
  /// Retourne null si refusé ou indisponible
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  /// Position par défaut (centre du Plateau, Dakar)
  static const double defaultLat = 14.6937;
  static const double defaultLng = -17.4441;

  /// Détermine le quartier approximatif à partir des coordonnées
  static String guessZone(double lat, double lng) {
    // Zones simplifiées de Dakar
    if (lat > 14.73 && lng < -17.49) return 'Almadies';
    if (lat > 14.73) return 'Ngor';
    if (lat > 14.70 && lng > -17.47) return 'Mermoz';
    if (lat > 14.68 && lng < -17.45) return 'Point E';
    if (lat > 14.68) return 'Médina';
    if (lat < 14.68) return 'Plateau';
    return 'Dakar';
  }
}