/// Helpers pour le formatage des prix en FCFA
class PriceFormatter {
  /// 3500 → "3 500"
  static String format(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }

  /// 3500 → "3 500 FCFA"
  static String formatWithCurrency(int price) => '${format(price)} FCFA';

  /// Fourchette: 2000, 8000 → "2 000 – 8 000 FCFA"
  static String formatRange(int min, int max) {
    return '${format(min)} – ${format(max)} FCFA';
  }

  /// Convertit euros en FCFA
  static int euroToFcfa(double euros) => (euros * 655).round();

  /// Convertit dollars en FCFA
  static int usdToFcfa(double usd) => (usd * 600).round();
}