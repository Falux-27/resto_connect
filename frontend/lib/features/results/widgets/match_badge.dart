import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Badge "88% match" affiché sur l'image de la card
class MatchBadge extends StatelessWidget {
  final int score;
  const MatchBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.matchBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.orange, size: 12),
          const SizedBox(width: 4),
          Text(
            '$score% match',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}