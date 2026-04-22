import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final RestaurantRepository _repo = RestaurantRepository();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  final RxString query         = ''.obs;
  final RxString zone          = 'Plateau'.obs;
  final RxDouble userLat       = 14.6937.obs;
  final RxDouble userLng       = (-17.4441).obs;
  final RxBool   locationReady = false.obs;
  final RxSet<String> activeFilters = <String>{}.obs;

  final suggestions = [
    'Thiéboudienne pas cher',
    'Végétarien Plateau',
    'Halal près du stade',
    'Vue mer Almadies',
  ];

  final quickFilters = [
    {'icon': '🕌', 'label': 'Halal',        'sub': 'Certifié',     'tag': 'halal'},
    {'icon': '🌿', 'label': 'Végétarien',   'sub': '& vegan',      'tag': 'vegetarien'},
    {'icon': '💸', 'label': 'Petit budget', 'sub': '< 3 500 FCFA', 'tag': 'cheap'},
    {'icon': '🌊', 'label': 'Vue mer',      'sub': 'Almadies',     'tag': 'vue mer'},
  ];

  @override
  void onInit() {
    super.onInit();
    _requestLocation();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    super.onClose();
  }

  // FIX: utilise desiredAccuracy au lieu de locationSettings
  // compatible geolocator ^9.x, ^10.x, ^11.x
  Future<void> _requestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { locationReady.value = true; return; }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        locationReady.value = true;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      userLat.value = pos.latitude;
      userLng.value = pos.longitude;
      locationReady.value = true;
    } catch (_) {
      locationReady.value = true;
    }
  }

  void onQueryChanged(String value) => query.value = value;

  void onSearch([String? overrideQuery]) {
    final q = (overrideQuery ?? query.value).trim();
    if (q.isEmpty && activeFilters.isEmpty) return;
    searchFocus.unfocus();

    Get.toNamed(AppRoutes.results, arguments: {
      'query':         q,
      'userLat':       userLat.value,
      'userLng':       userLng.value,
      'activeFilters': activeFilters.toList(),
    });
  }

  void onSuggestionTap(String suggestion) {
    searchController.text = suggestion;
    query.value = suggestion;
    onSearch(suggestion);
  }

  void toggleFilter(String tag) {
    if (activeFilters.contains(tag)) {
      activeFilters.remove(tag);
    } else {
      activeFilters.add(tag);
    }
  }

  bool isFilterActive(String tag) => activeFilters.contains(tag);

  void onFilterCardTap(String tag) {
    Get.toNamed(AppRoutes.results, arguments: {
      'query':         '',
      'userLat':       userLat.value,
      'userLng':       userLng.value,
      'activeFilters': [tag],
    });
  }

  void navigateToFavorites() => Get.toNamed(AppRoutes.favorites);
}