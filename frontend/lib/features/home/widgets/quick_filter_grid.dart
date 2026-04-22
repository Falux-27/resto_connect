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
        Text('Filtres rapides', style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        )),
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
              icon:  f['icon']!,
              label: f['label']!,
              sub:   f['sub']!,
              tag:   f['tag']!,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FilterCard extends GetView<HomeController> {
  final String icon;
  final String label;
  final String sub;
  final String tag;

  const _FilterCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.isFilterActive(tag);
      return GestureDetector(
        onTap: () => controller.onFilterCardTap(tag),
        onLongPress: () => controller.toggleFilter(tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.orange.withOpacity(0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: active
                ? Border.all(color: AppColors.orange, width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
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
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sub,
                      style: AppTextStyles.bodySmall,
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