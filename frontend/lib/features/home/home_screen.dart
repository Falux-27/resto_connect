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
import 'widgets/app_drawer.dart';

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
        key: controller.scaffoldKey,
        backgroundColor: AppColors.sand,
        drawer: const AppDrawer(),
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
                    padding: const EdgeInsets.fromLTRB(0, 24, 0, 48),
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

class _SearchModal extends StatefulWidget {
  const _SearchModal();

  @override
  State<_SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<_SearchModal> {
  late final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final q = _textCtrl.text.trim();
    if (q.isEmpty) return;
    Navigator.of(context).pop(q);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
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
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Demandez à Resto', style: AppTextStyles.h2),
                        const SizedBox(height: 2),
                        Text(
                          'FR · EN · ES · AR · parlez naturellement',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textCtrl,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: 'Un thiof grillé près du Plateau…',
                          hintStyle: AppTextStyles.inputHint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _submit,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Voice hint bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.07),
                border: Border(
                  top: BorderSide(color: AppColors.orange.withValues(alpha: 0.12), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WaveformIcon(),
                  const SizedBox(width: 10),
                  Text(
                    'Dictez ou tapez votre demande',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveformIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = AppColors.orange;
    const heights = [8.0, 14.0, 10.0, 18.0, 10.0, 14.0, 8.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights
          .map(
            (h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 3,
                height: h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
