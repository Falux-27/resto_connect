import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';

class PracticalInfoSection extends StatelessWidget {
  final RestaurantModel restaurant;
  final bool isOpen;

  const PracticalInfoSection({
    super.key,
    required this.restaurant,
    this.isOpen = true,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Infos pratiques', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.location_on_outlined,
          main: r.address.isNotEmpty ? r.address : '${r.zone}, Dakar',
          sub: r.distanceKm != null
              ? '${r.distanceLabel} · ${(r.distanceKm! * 12).round()} min à pied'
              : null,
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.access_time_rounded,
          main: r.openingHours.isNotEmpty ? r.openingHours : 'Horaires non renseignés',
          sub: isOpen ? 'Ouvert maintenant' : 'Fermé actuellement',
          subColor: isOpen ? AppColors.teal : Colors.redAccent,
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.phone_outlined,
          main: r.phone.isNotEmpty ? r.phone : 'Téléphone non renseigné',
          sub: 'Réserver par téléphone',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String main;
  final String? sub;
  final Color? subColor;
  const _InfoRow({required this.icon, required this.main, this.sub, this.subColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(main, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!, style: AppTextStyles.bodySmall.copyWith(
                    color: subColor ?? AppColors.muted,
                    fontWeight: FontWeight.w500,
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}