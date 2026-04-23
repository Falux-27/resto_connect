import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class QuickFilterGrid extends GetView<HomeController> {
  const QuickFilterGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres rapides',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: controller.quickFilters.map((f) {
            return _FilterCard(
              ctrl: controller,
              label: f['label']!,
              sub: f['sub']!,
              tag: f['tag']!,
            );
          }).toList(),
        ),
      ],
    );
  }
}

IconData _iconFor(String tag) {
  switch (tag) {
    case 'halal':      return Icons.verified_rounded;
    case 'vegetarien': return Icons.eco_rounded;
    case 'cheap':      return Icons.savings_rounded;
    case 'vue mer':    return Icons.beach_access_rounded;
    default:           return Icons.restaurant_rounded;
  }
}

Color _iconColorFor(String tag) {
  switch (tag) {
    case 'halal':      return const Color(0xFF16A34A); // vert halal
    case 'vegetarien': return const Color(0xFF15803D); // vert végé
    case 'cheap':      return AppColors.orange;         // orange budget
    case 'vue mer':    return AppColors.teal;            // bleu-vert mer
    default:           return AppColors.orange;
  }
}

class _FilterCard extends StatelessWidget {
  final HomeController ctrl;
  final String label;
  final String sub;
  final String tag;

  const _FilterCard({
    required this.ctrl,
    required this.label,
    required this.sub,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = ctrl.isFilterActive(tag);
      final iconColor = active ? AppColors.orange : _iconColorFor(tag);
      return GestureDetector(
        onTap: () => ctrl.onFilterCardTap(tag),
        onLongPress: () => ctrl.toggleFilter(tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.orange.withValues(alpha: 0.08) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: active
                ? Border.all(color: AppColors.orange, width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_iconFor(tag), size: 24, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: active ? AppColors.orange : AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sub,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
