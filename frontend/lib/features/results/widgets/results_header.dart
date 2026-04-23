import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ResultsHeader extends StatelessWidget {
  final String query;
  final VoidCallback onBack;

  const ResultsHeader({
    super.key,
    required this.query,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sand,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VOTRE RECHERCHE', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  '"$query"',
                  style: AppTextStyles.h3,
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