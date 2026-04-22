import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'home_controller.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/suggestion_chips_widget.dart';
import 'widgets/quick_filter_grid.dart';
import 'widgets/ai_hint_banner.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Status bar light (fond sable)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: GestureDetector(
          // Ferme le clavier si on tape en dehors
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            slivers: [
              // ─── Header (menu + favoris) ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _buildHeader(),
                ),
              ),

              // ─── Titre hero ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildHeroTitle(),
                ),
              ),

              // ─── Search bar ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: const SearchBarWidget(),
                ),
              ),

              // ─── Localisation chip ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _buildLocationChip(),
                ),
              ),

              // ─── Suggestions ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: const SuggestionChipsWidget(),
                ),
              ),

              // ─── Filtres rapides ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: const QuickFilterGrid(),
                ),
              ),

              // ─── AI Hint Banner ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: const AiHintBanner(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu burger
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: AppColors.ink,
            size: 20,
          ),
        ),

        // Favoris
        GestureDetector(
          onTap: controller.navigateToFavorites,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.ink,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Titre hero ───────────────────────────────────────────
  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BONJOUR 👋',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 6),
        Text(
          'Qu\'est-ce qu\'on\nmange à Dakar ?',
          style: AppTextStyles.heroTitle,
        ),
      ],
    );
  }

  // ─── Location chip ────────────────────────────────────────
  Widget _buildLocationChip() {
    return Obx(() => Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.muted,
            ),
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