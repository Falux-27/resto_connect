import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_controller.dart';

class SearchBarWidget extends GetView<HomeController> {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              focusNode: controller.searchFocus,
              onChanged: controller.onQueryChanged,
              onSubmitted: (_) => controller.onSearch(),
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'Qu\'est-ce que vous cherchez ?',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_outlined, color: AppColors.muted, size: 22),
            onPressed: () {/* TODO: speech-to-text */},
            padding: const EdgeInsets.only(right: 4),
          ),
        ],
      ),
    );
  }
}
