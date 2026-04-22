import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';
import 'match_badge.dart';
import 'recommended_dish_chip.dart';
import 'tags_row.dart';
import 'why_recommended_row.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero image ─────────────────────────────────
            _buildHeroImage(r),

            // ─── Infos principales ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: _buildInfoRow(r),
            ),

            // ─── Plat recommandé ────────────────────────────
            if (r.recommendedDish != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: RecommendedDishChip(dishName: r.recommendedDish!),
              ),

            // ─── Tags ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: TagsRow(
                tags: r.tags
                    .where((t) => ['halal', 'terrasse', 'climatisé',
                                   'wifi', 'vue mer', 'végétarien'].contains(t))
                    .map((t) => t.toUpperCase())
                    .toList(),
                maxVisible: 4,
              ),
            ),

            // ─── Pourquoi recommandé ─────────────────────────
            if (r.whyRecommended.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: WhyRecommendedRow(reasons: r.whyRecommended),
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // ─── Image hero avec overlays ─────────────────────────────
  Widget _buildHeroImage(RestaurantModel r) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: r.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.divider,
                highlightColor: AppColors.cardBg,
                child: Container(color: AppColors.white),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.cardBg,
                child: const Center(
                  child: Icon(Icons.restaurant_rounded,
                      color: AppColors.muted, size: 40),
                ),
              ),
            ),

            // Dégradé bas pour le nom
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Nom + zone + distance (bas gauche)
            Positioned(
              left: 14, bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        r.distanceKm != null
                            ? '${r.zone} · ${r.distanceLabel}'
                            : r.zone,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge match (haut gauche)
            if (r.matchScore != null && r.matchScore! > 70)
              Positioned(
                top: 12, left: 12,
                child: MatchBadge(score: r.matchScore!),
              ),

            // Favori (haut droite)
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.ink,
                  size: 18,
                ),
              ),
            ),

            // Note étoile (bas droite)
            Positioned(
              right: 12, bottom: 12,
              child: _RatingBadge(rating: r.rating),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Ligne cuisine · fourchette prix ─────────────────────
  Widget _buildInfoRow(RestaurantModel r) {
    // Cuisine déduite des tags
    final cuisine = r.tags
        .where((t) => ['senegalais', 'africain', 'fusion',
                        'fruits de mer', 'grillades'].contains(t))
        .map((t) => t[0].toUpperCase() + t.substring(1))
        .take(2)
        .join(' · ');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          cuisine.isNotEmpty ? cuisine : r.zone,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          r.priceDisplay,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ─── Badge étoile ─────────────────────────────────────────
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.star, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.rating,
          ),
        ],
      ),
    );
  }
}