import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RecommendedDishChip extends StatelessWidget {
  final String dishName;
  const RecommendedDishChip({super.key, required this.dishName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icône plat
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('🍽️', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAT RECOMMANDÉ',
                  style: AppTextStyles.labelCaps.copyWith(fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  dishName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}