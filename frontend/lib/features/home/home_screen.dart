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
import 'widgets/location_chip_widget.dart';
import 'widgets/animated_mascot.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sand,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _buildHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildHeroTitle(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: SearchBarWidget(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: LocationChipWidget(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SuggestionChipsWidget(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: QuickFilterGrid(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 56),
                    child: AiHintBanner(
                      onTap: () => _showSearchModal(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchModal(BuildContext context) async {
    final query = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SearchModal(),
    );
    if (query != null && query.isNotEmpty) {
      controller.onSearch(query);
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: controller.openMenu,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_rounded, color: AppColors.ink, size: 20),
          ),
        ),
        const Expanded(
          child: Center(child: AnimatedMascot()),
        ),
        GestureDetector(
          onTap: controller.navigateToFavorites,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_border_rounded, color: AppColors.ink, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BONJOUR', style: AppTextStyles.label),
        const SizedBox(height: 6),
        Text("On mange quoi à Dakar ?", style: AppTextStyles.heroTitle),
      ],
    );
  }
}

// Widget stateful séparé pour le modal — gère le clavier sans conflit de contexte.
class _SearchModal extends StatefulWidget {
  final TextEditingController textCtrl;
  const _SearchModal({required this.textCtrl});

  @override
  State<_SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<_SearchModal> {
  void _submit() {
    final q = widget.textCtrl.text.trim();
    if (q.isEmpty) return;
    Navigator.of(context).pop(q);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Que cherchez-vous ?', style: AppTextStyles.h2),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                'Posez votre question normalement',
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: widget.textCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'Ex: halal près du stade, vue mer…',
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.muted,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text('Rechercher', style: AppTextStyles.button),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
