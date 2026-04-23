import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/local/restaurants_seed.dart';

class FavoritesController extends GetxController {
  final RxList<RestaurantModel> favorites = <RestaurantModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    favorites.value = restaurantsSeed.where((r) => ids.contains(r.id)).toList();
    isLoading.value = false;
  }

  Future<bool> isFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    return ids.contains(id);
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList('favorites', ids);
    await loadFavorites();
  }
}