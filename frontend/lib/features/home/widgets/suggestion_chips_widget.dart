import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class SuggestionChipsWidget extends GetView<HomeController> {
  const SuggestionChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Essayez', style: AppTextStyles.bodyMedium),
            const SizedBox(width: 6),
            Text('· populaire cette semaine', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: controller.suggestions.map((s) {
              final isFirst = controller.suggestions.indexOf(s) == 0;
              return Padding(
                padding: EdgeInsets.only(
                  right: 8,
                  left: isFirst ? 0 : 0,
                ),
                child: _SuggestionChip(label: s),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends GetView<HomeController> {
  final String label;
  const _SuggestionChip({required this.label});

  // Emoji par mot-clé
  String get emoji {
    final l = label.toLowerCase();
    if (l.contains('thiébou') || l.contains('thiebou')) return '🐟';
    if (l.contains('végétar') || l.contains('vegetar')) return '🌿';
    if (l.contains('halal'))   return '🕌';
    if (l.contains('mer'))     return '🌊';
    if (l.contains('budget'))  return '💸';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onSuggestionTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}