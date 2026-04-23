import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';

/// Carte de recommandation IA affichée dans l'écran détail
class AiRecommendationCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final String explanation;

  const AiRecommendationCard({
    super.key,
    required this.restaurant,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pourquoi JOJ'Eat recommande",
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    if (restaurant.matchScore != null)
                      Text('SCORE ${restaurant.matchScore} / 100',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.teal)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(explanation, style: AppTextStyles.body),
        ],
      ),
    );
  }
}