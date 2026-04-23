import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class LocationChipWidget extends GetView<HomeController> {
  const LocationChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          '${controller.zone.value} · '
          '${controller.locationReady.value ? 'à moins de 3 km' : 'Localisation...'}'
          ' · basé sur votre position',
          style: AppTextStyles.bodySmall,
        ),
      ],
    ));
  }
}