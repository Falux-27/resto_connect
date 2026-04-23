import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'results_controller.dart';
import 'widgets/restaurant_card.dart';

class ResultsScreen extends GetView<ResultsController> {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Obx(() => controller.isLoading.value
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      if (controller.isOfflineFallback.value) _buildOfflineBanner(),
                      _buildAiBanner(),
                    ],
                  )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return _buildSkeleton();
                if (controller.results.isEmpty)  return _buildEmpty();
                return _buildList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.sand,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
            onPressed: controller.goBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VOTRE RECHERCHE', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Obx(() => Text(
                  '"${controller.query.value}"',
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.orangeLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Backend non joignable — résultats locaux uniquement.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() => Text(
                controller.resultsSummary,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink, fontWeight: FontWeight.w500),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: controller.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final r = controller.results[i];
        return RestaurantCard(restaurant: r, onTap: () => controller.onRestaurantTap(r));
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('Aucun restaurant trouvé', style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Essayez avec des mots différents\nou un autre filtre.',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: controller.goBack, child: const Text('Nouvelle recherche')),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.white,
        child: Container(
          height: 300,
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}