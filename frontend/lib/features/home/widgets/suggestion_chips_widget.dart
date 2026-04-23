import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class SuggestionChipsWidget extends GetView<HomeController> {
  const SuggestionChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Essayez',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text('· populaire cette semaine', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: _InfiniteScrollChips(
            suggestions: controller.suggestions,
            onTap: controller.onSuggestionTap,
          ),
        ),
      ],
    );
  }
}

IconData _iconForLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('thiébou') || l.contains('thiebou')) return Icons.set_meal_rounded;
  if (l.contains('végétar') || l.contains('vegetar'))  return Icons.eco_rounded;
  if (l.contains('halal'))                             return Icons.verified_rounded;
  if (l.contains('mer'))                               return Icons.beach_access_rounded;
  if (l.contains('budget') || l.contains('cher'))      return Icons.savings_rounded;
  return Icons.auto_awesome_rounded;
}

Color _colorForLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('thiébou') || l.contains('thiebou')) return const Color(0xFFEA580C); // orange brûlé
  if (l.contains('végétar') || l.contains('vegetar'))  return const Color(0xFF15803D); // vert végé
  if (l.contains('halal'))                             return const Color(0xFF16A34A); // vert halal
  if (l.contains('mer'))                               return AppColors.teal;           // teal mer
  if (l.contains('budget') || l.contains('cher'))      return AppColors.orange;         // orange budget
  return AppColors.orange;
}

class _InfiniteScrollChips extends StatefulWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const _InfiniteScrollChips({
    required this.suggestions,
    required this.onTap,
  });

  @override
  State<_InfiniteScrollChips> createState() => _InfiniteScrollChipsState();
}

class _InfiniteScrollChipsState extends State<_InfiniteScrollChips>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;
  late final List<String> _items;
  double _singleSetWidth = 0;
  bool _userTouching = false;

  static const double _speed = 30.0;

  @override
  void initState() {
    super.initState();
    _items = [
      ...widget.suggestions,
      ...widget.suggestions,
      ...widget.suggestions,
    ];
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!mounted) return;
    final pos = _scrollController.position;
    _singleSetWidth = (pos.maxScrollExtent + pos.viewportDimension) / 3;
    if (_singleSetWidth <= 0) return;

    final durationMs = (_singleSetWidth / _speed * 1000).round();
    _animController.duration = Duration(milliseconds: durationMs);
    _animController.addListener(_onTick);
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scrollController.jumpTo(_scrollController.offset - _singleSetWidth);
        _animController.reset();
        if (!_userTouching) _animController.forward();
      }
    });
    _animController.forward();
  }

  void _onTick() {
    if (!mounted || _userTouching) return;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_animController.value * _singleSetWidth);
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _userTouching = true;
        _animController.stop();
      },
      onPointerUp: (_) {
        _userTouching = false;
        if (_scrollController.hasClients && _singleSetWidth > 0) {
          final offset = _scrollController.offset % _singleSetWidth;
          _scrollController.jumpTo(offset);
          _animController.value = offset / _singleSetWidth;
          _animController.forward();
        }
      },
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = _items[i];
          return _SuggestionChip(
            label: label,
            onTap: () => widget.onTap(label),
          );
        },
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconForLabel(label),
              size: 15,
              color: _colorForLabel(label),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
