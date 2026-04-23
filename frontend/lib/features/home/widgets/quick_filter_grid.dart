// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../../core/constants/app_colors.dart';
// // import '../../../core/constants/app_text_styles.dart';
// // import '../home_controller.dart';

// // class QuickFilterGrid extends GetView<HomeController> {
// //   const QuickFilterGrid({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text('Filtres rapides', style: AppTextStyles.bodyMedium.copyWith(
// //           fontWeight: FontWeight.w600,
// //         )),
// //         const SizedBox(height: 12),
// //         GridView.count(
// //           crossAxisCount: 2,
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           crossAxisSpacing: 10,
// //           mainAxisSpacing: 10,
// //           childAspectRatio: 2.4,
// //           children: controller.quickFilters.map((f) {
// //             return _FilterCard(
// //               icon:  f['icon']!,
// //               label: f['label']!,
// //               sub:   f['sub']!,
// //               tag:   f['tag']!,
// //             );
// //           }).toList(),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class _FilterCard extends GetView<HomeController> {
// //   final String icon;
// //   final String label;
// //   final String sub;
// //   final String tag;

// //   const _FilterCard({
// //     required this.icon,
// //     required this.label,
// //     required this.sub,
// //     required this.tag,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Obx(() {
// //       final active = controller.isFilterActive(tag);
// //       return GestureDetector(
// //         onTap: () => controller.onFilterCardTap(tag),
// //         onLongPress: () => controller.toggleFilter(tag),
// //         child: AnimatedContainer(
// //           duration: const Duration(milliseconds: 180),
// //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// //           decoration: BoxDecoration(
// //             color: active ? AppColors.orange.withOpacity(0.1) : AppColors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             border: active
// //                 ? Border.all(color: AppColors.orange, width: 1.5)
// //                 : Border.all(color: Colors.transparent),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.05),
// //                 blurRadius: 6,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Row(
// //             children: [
// //               Text(icon, style: const TextStyle(fontSize: 22)),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       label,
// //                       style: AppTextStyles.bodyMedium.copyWith(
// //                         color: active ? AppColors.orange : AppColors.ink,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     Text(
// //                       sub,
// //                       style: AppTextStyles.bodySmall,
// //                       maxLines: 1,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     });
// //   }
// // }



// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import 'package:get/get.dart';
// import '../../../core/constants/app_text_styles.dart';
// import '../home_controller.dart';

// class QuickFilterGrid extends StatelessWidget {
//   final HomeController ctrl;
//   const QuickFilterGrid({required this.ctrl, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Filtres rapides', style: AppTextStyles.bodyMedium.copyWith(
//           fontWeight: FontWeight.w600,
//         )),
//         const SizedBox(height: 12),
//         GridView.count(
//           crossAxisCount: 2,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: 2.4,
//           children: ctrl.quickFilters.map((f) => _FilterCard(
//             ctrl: ctrl,
//             icon:  f['icon']!,
//             label: f['label']!,
//             sub:   f['sub']!,
//             tag:   f['tag']!,
//           )).toList(),
//         ),
//       ],
//     );
//   }
// }

// class _FilterCard extends StatelessWidget {
//   final HomeController ctrl;
//   final String icon, label, sub, tag;

//   const _FilterCard({
//     required this.ctrl,
//     required this.icon,
//     required this.label,
//     required this.sub,
//     required this.tag,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final active = ctrl.isFilterActive(tag);
//       return GestureDetector(
//         onTap: () => ctrl.onFilterCardTap(tag),
//         onLongPress: () => ctrl.toggleFilter(tag),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: active ? AppColors.orange.withOpacity(0.1) : AppColors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: active
//                 ? Border.all(color: AppColors.orange, width: 1.5)
//                 : Border.all(color: Colors.transparent),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Text(icon, style: const TextStyle(fontSize: 22)),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(label,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: active ? AppColors.orange : AppColors.ink,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(sub, style: AppTextStyles.bodySmall, maxLines: 1),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }






import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class QuickFilterGrid extends StatelessWidget {
  final HomeController ctrl;
  const QuickFilterGrid({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres rapides',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: ctrl.quickFilters.map((f) => _FilterCard(
            icon:  f['icon']!,
            label: f['label']!,
            sub:   f['sub']!,
            tag:   f['tag']!,
            ctrl:  ctrl,
          )).toList(),
        ),
      ],
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String icon, label, sub, tag;
  final HomeController ctrl;

  const _FilterCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.tag,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = ctrl.isFilterActive(tag);
      return GestureDetector(
        onTap: () => ctrl.onFilterCardTap(tag),
        onLongPress: () => ctrl.toggleFilter(tag),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.orange.withOpacity(0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: active
                ? Border.all(color: AppColors.orange, width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: active ? AppColors.orange : AppColors.ink,
                        fontWeight: FontWeight.w700, // gras
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sub,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}