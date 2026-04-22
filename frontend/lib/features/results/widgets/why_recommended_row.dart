import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class WhyRecommendedRow extends StatelessWidget {
  final List<String> reasons;
  const WhyRecommendedRow({super.key, required this.reasons});

  IconData _icon(String reason) {
    switch (reason) {
      case 'Proche':           return Icons.near_me_rounded;
      case 'Dans le budget':   return Icons.payments_outlined;
      case 'Match recherche':  return Icons.auto_awesome_rounded;
      default:                 return Icons.check_circle_outline_rounded;
    }
  }

  Color _color(String reason) {
    switch (reason) {
      case 'Proche':           return AppColors.teal;
      case 'Dans le budget':   return AppColors.orange;
      case 'Match recherche':  return const Color(0xFF8B5CF6); // violet
      default:                 return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: AppColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              'POURQUOI RECOMMANDÉ ?',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: reasons.map((r) => _ReasonChip(
            label: r,
            icon:  _icon(r),
            color: _color(r),
          )).toList(),
        ),
      ],
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _ReasonChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}