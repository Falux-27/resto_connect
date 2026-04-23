import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';
import '../../results/widgets/tags_row.dart';

class RestaurantInfoHeader extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantInfoHeader({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(r.name, style: AppTextStyles.h1)),
            const SizedBox(width: 12),
            Column(
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
                  const SizedBox(width: 3),
                  Text(r.rating.toStringAsFixed(1), style: AppTextStyles.h3),
                ]),
                Text('NOTE', style: AppTextStyles.bodySmall.copyWith(fontSize: 9, letterSpacing: 0.8)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.muted),
            const SizedBox(width: 2),
            Text(r.zone, style: AppTextStyles.bodySmall),
            if (r.distanceKm != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('·', style: AppTextStyles.bodySmall),
              ),
              Text(r.distanceLabel, style: AppTextStyles.bodySmall),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TagsRow(
          tags: r.tags
              .where((t) => ['halal', 'terrasse', 'climatisé', 'wifi', 'vue mer', 'végétarien'].contains(t))
              .map((t) => t.toUpperCase())
              .toList(),
          maxVisible: 5,
        ),
      ],
    );
  }
}