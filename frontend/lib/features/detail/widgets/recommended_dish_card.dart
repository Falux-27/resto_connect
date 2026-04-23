import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../core/utils/price_formatter.dart';

class RecommendedDishCard extends StatelessWidget {
  final MenuItemModel dish;

  const RecommendedDishCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🍛', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: AppTextStyles.h3),
                const SizedBox(height: 3),
                Text('Spécialité de la maison',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.orange)),
              ],
            ),
          ),
          Text(PriceFormatter.formatWithCurrency(dish.price),
              style: AppTextStyles.price.copyWith(color: AppColors.orange)),
        ],
      ),
    );
  }
}