import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/restaurant_repository.dart';

class DetailController extends GetxController {
  final RestaurantRepository _repo = RestaurantRepository();

  // ─── State ─────────────────────────────────────────────────
  final Rx<RestaurantModel?> restaurant = Rx<RestaurantModel?>(null);
  final RxBool isFavorite = false.obs;
  final RxBool isLoading  = true.obs;
  final RxString query    = ''.obs;

  // ─── Lifecycle ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final id   = args['restaurantId'] as String? ?? '';
    query.value = args['query']        as String? ?? '';
    _load(id);
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 120));
    restaurant.value = _repo.getById(id);
    await _loadFavoriteState(id);
    isLoading.value = false;
  }

  // ─── Favoris (persistants) ─────────────────────────────────
  Future<void> _loadFavoriteState(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs  = prefs.getStringList('favorites') ?? [];
    isFavorite.value = favs.contains(id);
  }

  Future<void> toggleFavorite() async {
    final r = restaurant.value;
    if (r == null) return;
    final prefs = await SharedPreferences.getInstance();
    final favs  = prefs.getStringList('favorites') ?? [];
    if (isFavorite.value) {
      favs.remove(r.id);
    } else {
      favs.add(r.id);
    }
    await prefs.setStringList('favorites', favs);
    isFavorite.value = !isFavorite.value;
  }

  // ─── Navigation ────────────────────────────────────────────
  void goBack() => Get.back();

  // ─── Helpers ───────────────────────────────────────────────
  bool get isOpen {
    final now = DateTime.now();
    final hour = now.hour;
    // Heuristique simple : ouvert entre 8h et 23h
    return hour >= 8 && hour < 23;
  }

  String get aiExplanation {
    final r = restaurant.value;
    if (r == null) return '';
    final dist   = r.distanceKm != null ? '${r.distanceLabel} à pied, ' : '';
    final budget  = r.priceRange == PriceRange.cheap ? 'pile dans votre budget, ' : '';
    final match   = query.value.isNotEmpty
        ? 'et spécialiste ${query.value.contains('thiébou') ? 'du Thiéboudienne' : 'de ce que vous cherchez'}.'
        : 'et très bien noté par les locaux.';
    return '${dist}${budget}$match';
  }
}