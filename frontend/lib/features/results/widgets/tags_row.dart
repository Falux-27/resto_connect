import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TagsRow extends StatelessWidget {
  final List<String> tags;
  final int maxVisible;

  const TagsRow({
    super.key,
    required this.tags,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(maxVisible).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: visible.map((t) => _Tag(label: t)).toList(),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  bool get isHalal  => label.toLowerCase() == 'halal';
  bool get isVege   => label.toLowerCase().contains('végé') ||
                       label.toLowerCase().contains('vegan');
  bool get isVueMer => label.toLowerCase().contains('mer');

  Color get bg {
    if (isHalal)  return AppColors.halalBg;
    if (isVege)   return AppColors.vegeBg;
    return AppColors.tagBg;
  }

  Color get fg {
    if (isHalal)  return AppColors.halalText;
    if (isVege)   return AppColors.vegeText;
    return AppColors.tagText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}