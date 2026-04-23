import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../data/models/menu_item_model.dart';

class MenuSection extends StatelessWidget {
  final List<MenuItemModel> items;

  const MenuSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menu', style: AppTextStyles.h3),
            Text('${items.length} plat${items.length > 1 ? "s" : ""}',
                style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink)),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(item.description, style: AppTextStyles.bodySmall, maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(PriceFormatter.formatWithCurrency(item.price),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        )),
      ],
    );
  }
}