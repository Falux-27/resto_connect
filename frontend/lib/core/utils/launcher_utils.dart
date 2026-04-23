import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'app téléphone avec le numéro pré-rempli
Future<void> launchPhone(String phone) async {
  // Nettoyer : garder uniquement +, chiffres et espaces
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri(scheme: 'tel', path: cleaned);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

/// Ouvre Google Maps sur les coordonnées données
/// Fallback sur l'URL web si l'app n'est pas installée
Future<void> launchGoogleMaps({
  required double lat,
  required double lng,
  String? label,
}) async {
  // Lien deep-link Google Maps natif (iOS + Android)
  final geoUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1'
    '&query=$lat,$lng'
    '${label != null ? '&query_place_name=${Uri.encodeComponent(label)}' : ''}',
  );

  // Sur Android : essayer d'abord l'intent natif
  final nativeUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng${label != null ? '(${Uri.encodeComponent(label)})' : ''}');

  if (await canLaunchUrl(nativeUri)) {
    await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(geoUri)) {
    await launchUrl(geoUri, mode: LaunchMode.externalApplication);
  }
}