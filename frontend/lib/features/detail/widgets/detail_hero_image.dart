import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';

class DetailHeroImage extends StatelessWidget {
  final RestaurantModel restaurant;

  const DetailHeroImage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: restaurant.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: AppColors.divider,
              highlightColor: AppColors.cardBg,
              child: Container(color: AppColors.white),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.cardBg,
              child: const Center(
                child: Icon(Icons.restaurant_rounded, color: AppColors.muted, size: 60),
              ),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}