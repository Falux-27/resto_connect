import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/local/restaurants_seed.dart';
import '../../data/models/restaurant_model.dart';
import '../results/widgets/restaurant_card.dart';
import '../../routes/app_routes.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<RestaurantModel> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids   = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites = restaurantsSeed.where((r) => ids.contains(r.id)).toList();
      _loading   = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: Get.back,
        ),
        title: Text('Mes favoris', style: AppTextStyles.h3),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _favorites.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final r = _favorites[i];
        return RestaurantCard(
          restaurant: r,
          onTap: () => Get.toNamed(
            AppRoutes.detail,
            arguments: {'restaurantId': r.id, 'query': ''},
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('❤️', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('Aucun favori', style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Appuie sur ♡ dans un restaurant\npour l\'ajouter ici.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}