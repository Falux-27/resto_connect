// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../../core/constants/app_colors.dart';
// // import '../../../core/constants/app_text_styles.dart';
// // import '../home_controller.dart';

// // class SuggestionChipsWidget extends GetView<HomeController> {
// //   const SuggestionChipsWidget({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text('Essayez', style: AppTextStyles.bodyMedium),
// //             const SizedBox(width: 6),
// //             Text('· populaire cette semaine', style: AppTextStyles.bodySmall),
// //           ],
// //         ),
// //         const SizedBox(height: 10),
// //         SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           clipBehavior: Clip.none,
// //           child: Row(
// //             children: controller.suggestions.map((s) {
// //               final isFirst = controller.suggestions.indexOf(s) == 0;
// //               return Padding(
// //                 padding: EdgeInsets.only(
// //                   right: 8,
// //                   left: isFirst ? 0 : 0,
// //                 ),
// //                 child: _SuggestionChip(label: s),
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class _SuggestionChip extends GetView<HomeController> {
// //   final String label;
// //   const _SuggestionChip({required this.label});

// //   // Emoji par mot-clé
// //   String get emoji {
// //     final l = label.toLowerCase();
// //     if (l.contains('thiébou') || l.contains('thiebou')) return '🐟';
// //     if (l.contains('végétar') || l.contains('vegetar')) return '🌿';
// //     if (l.contains('halal'))   return '🕌';
// //     if (l.contains('mer'))     return '🌊';
// //     if (l.contains('budget'))  return '💸';
// //     return '✨';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => controller.onSuggestionTap(label),
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// //         decoration: BoxDecoration(
// //           color: AppColors.white,
// //           borderRadius: BorderRadius.circular(50),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 6,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(emoji, style: const TextStyle(fontSize: 14)),
// //             const SizedBox(width: 6),
// //             Text(label, style: AppTextStyles.bodyMedium),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }










// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../home_controller.dart';

// class SuggestionChipsWidget extends StatelessWidget {
//   final HomeController ctrl;
//   const SuggestionChipsWidget({required this.ctrl, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text('Essayez', style: AppTextStyles.bodyMedium),
//             const SizedBox(width: 6),
//             Text('· populaire cette semaine', style: AppTextStyles.bodySmall),
//           ],
//         ),
//         const SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           child: Row(
//             children: ctrl.suggestions.map((s) => Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: _SuggestionChip(ctrl: ctrl, label: s),
//             )).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _SuggestionChip extends StatelessWidget {
//   final HomeController ctrl;
//   final String label;
//   const _SuggestionChip({required this.ctrl, required this.label});

//   String get emoji {
//     final l = label.toLowerCase();
//     if (l.contains('thiébou') || l.contains('thiebou')) return '🐟';
//     if (l.contains('végétar') || l.contains('vegetar')) return '🌿';
//     if (l.contains('halal'))  return '🕌';
//     if (l.contains('mer'))    return '🌊';
//     if (l.contains('budget')) return '💸';
//     return '✨';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => ctrl.onSuggestionTap(label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 14)),
//             const SizedBox(width: 6),
//             Text(label, style: AppTextStyles.bodyMedium),
//           ],
//         ),
//       ),
//     );
//   }
// }

















import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class SuggestionChipsWidget extends StatefulWidget {
  final HomeController ctrl;
  const SuggestionChipsWidget({super.key, required this.ctrl});

  @override
  State<SuggestionChipsWidget> createState() => _SuggestionChipsWidgetState();
}

class _SuggestionChipsWidgetState extends State<SuggestionChipsWidget> {
  late final ScrollController _scrollController;
  // On triple la liste pour simuler un défilement infini
  late final List<String> _infiniteList;

  @override
  void initState() {
    super.initState();
    final base = widget.ctrl.suggestions;
    _infiniteList = [...base, ...base, ...base];

    _scrollController = ScrollController();

    // Démarrer au milieu (index 1 * longueur de base)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToMiddle();
      _startAutoScroll();
    });
  }

  void _jumpToMiddle() {
    if (!_scrollController.hasClients) return;
    final base = widget.ctrl.suggestions.length;
    // Scroll au début du 2e bloc (milieu)
    final itemWidth = 180.0; // estimation largeur chip + spacing
    _scrollController.jumpTo(base * itemWidth);
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_scrollController.hasClients) break;

      final maxScroll  = _scrollController.position.maxScrollExtent;
      final minScroll  = _scrollController.position.minScrollExtent;
      final current    = _scrollController.offset;
      final base       = widget.ctrl.suggestions.length;
      final itemWidth  = 180.0;
      final loopMiddle = base * itemWidth;
      final loopEnd    = base * 2 * itemWidth;

      // Scroll vers la droite
      await _scrollController.animateTo(
        current + itemWidth,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      if (!mounted) break;

      // Quand on approche de la fin du 3e bloc, reset silencieux au milieu
      if (_scrollController.offset >= loopEnd - itemWidth) {
        _scrollController.jumpTo(loopMiddle);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Essayez',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(width: 6),
            Text('· populaire cette semaine',
                style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _infiniteList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _SuggestionChip(
              label: _infiniteList[i],
              onTap: () => widget.ctrl.onSuggestionTap(_infiniteList[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  String get emoji {
    final l = label.toLowerCase();
    if (l.contains('thiébou') || l.contains('thiebou')) return '🐟';
    if (l.contains('végétar') || l.contains('vegetar')) return '🌿';
    if (l.contains('halal'))  return '🕌';
    if (l.contains('mer'))    return '🌊';
    if (l.contains('budget')) return '💸';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}