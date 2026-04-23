import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/restaurant_model.dart';

class MapPreviewWidget extends StatelessWidget {
  final RestaurantModel restaurant;

  const MapPreviewWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emplacement', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEEC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(size: const Size(double.infinity, 160), painter: _MapPainter()),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.white, size: 22),
                      ),
                      Container(
                        width: 12, height: 6,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12, bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond_outlined, size: 13, color: AppColors.orange),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.distanceKm != null ? restaurant.distanceLabel : restaurant.zone,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600, color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4DDD9)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final p1 = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.3,
          size.width * 0.65, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.7,
          size.width, size.height * 0.6);
    canvas.drawPath(p1, paint);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.7)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.85,
            size.width * 0.5, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.65,
            size.width, size.height * 0.8),
      paint..color = const Color(0xFFC8D4CE),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}