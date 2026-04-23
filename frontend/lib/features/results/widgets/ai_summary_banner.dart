import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AiSummaryBanner extends StatelessWidget {
  final String summary;
  final bool fromCache;

  const AiSummaryBanner({
    super.key,
    required this.summary,
    this.fromCache = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summary,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (fromCache)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text('⚡', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}