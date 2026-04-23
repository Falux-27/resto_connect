 

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/launcher_utils.dart';
import '../../data/models/restaurant_model.dart';
import '../results/widgets/tags_row.dart';
import '../results/widgets/why_recommended_row.dart';
import 'detail_controller.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (controller.isLoading.value) return _buildSkeleton();
        final r = controller.restaurant.value;
        if (r == null) return _buildNotFound();
        return _buildContent(r);
      }),
    );
  }

  // ─── Contenu principal ────────────────────────────────────
  Widget _buildContent(RestaurantModel r) {
    return CustomScrollView(
      slivers: [
        _buildSliverHero(r),
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoHeader(r),
                const _Divider(),
                _buildAiCard(r),
                const _Divider(),
                if (r.recommendedDish != null) ...[
                  _buildRecommendedDish(r),
                  const _Divider(),
                ],
                _buildMenuSection(r),
                const _Divider(),
                _buildPracticalInfo(r),
                const _Divider(),
                _buildMapSection(r),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Hero image ───────────────────────────────────────────
  SliverAppBar _buildSliverHero(RestaurantModel r) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: controller.goBack,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.ink),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Obx(() => GestureDetector(
            onTap: controller.toggleFavorite,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isFavorite.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
                color: controller.isFavorite.value
                    ? Colors.redAccent
                    : AppColors.ink,
              ),
            ),
          )),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: r.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: AppColors.divider,
            highlightColor: AppColors.cardBg,
            child: Container(color: AppColors.white),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.cardBg,
            child: const Center(
              child: Icon(Icons.restaurant_rounded,
                  color: AppColors.muted, size: 60),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Info header ──────────────────────────────────────────
  Widget _buildInfoHeader(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(r.name, style: AppTextStyles.h1)),
              const SizedBox(width: 12),
              Column(
                children: [
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
                    const SizedBox(width: 3),
                    Text(r.rating.toStringAsFixed(1), style: AppTextStyles.h3),
                  ]),
                  Text('NOTE',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontSize: 9, letterSpacing: 0.8)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            Text(_cuisineLabel(r),
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w500)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('·', style: AppTextStyles.bodySmall),
            ),
            const Icon(Icons.location_on_outlined,
                size: 13, color: AppColors.muted),
            const SizedBox(width: 2),
            Text(r.zone, style: AppTextStyles.bodySmall),
          ]),
          const SizedBox(height: 12),
          TagsRow(
            tags: r.tags
                .where((t) => ['halal', 'terrasse', 'climatisé',
                               'wifi', 'vue mer', 'végétarien'].contains(t))
                .map((t) => t.toUpperCase())
                .toList(),
            maxVisible: 5,
          ),
        ],
      ),
    );
  }

  // ─── Carte IA ─────────────────────────────────────────────
  Widget _buildAiCard(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tealLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pourquoi Resto recommande',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    if (r.matchScore != null)
                      Text('SCORE ${r.matchScore} / 100',
                          style: AppTextStyles.labelCaps
                              .copyWith(color: AppColors.teal)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (r.whyRecommended.isNotEmpty)
              WhyRecommendedRow(reasons: r.whyRecommended),
            const SizedBox(height: 10),
            Text(controller.aiExplanation, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  // ─── Plat recommandé ─────────────────────────────────────
  Widget _buildRecommendedDish(RestaurantModel r) {
    final dish = r.menu.firstWhere(
      (m) => m.name == r.recommendedDish,
      orElse: () => r.menu.first,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plat recommandé', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Text('🍛', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name, style: AppTextStyles.h3),
                    const SizedBox(height: 3),
                    Text('Spécialité · demandé 3× aujourd\'hui',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.orange)),
                  ],
                ),
              ),
              Text('${_fmt(dish.price)} FCFA',
                  style: AppTextStyles.price.copyWith(color: AppColors.orange)),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── Menu complet ─────────────────────────────────────────
  Widget _buildMenuSection(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu', style: AppTextStyles.h3),
              Text('${r.menu.length} plat${r.menu.length > 1 ? "s" : ""}',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          ...r.menu.map((item) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(children: [
                  Expanded(
                    child: Text(item.name,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.ink)),
                  ),
                  const SizedBox(width: 16),
                  Text('${_fmt(item.price)} FCFA',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
              if (item != r.menu.last)
                Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
            ],
          )),
        ],
      ),
    );
  }

  // ─── Infos pratiques avec tap fonctionnel ─────────────────
  Widget _buildPracticalInfo(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Infos pratiques', style: AppTextStyles.h3),
          const SizedBox(height: 12),

          // Adresse — tap ouvre Google Maps
          _InfoRow(
            icon: Icons.location_on_outlined,
            main: r.address.isNotEmpty ? r.address : '${r.zone}, Dakar',
            sub: r.distanceKm != null
                ? '${r.distanceLabel} · ${(r.distanceKm! * 12).round()} min à pied'
                : null,
            onTap: () => launchGoogleMaps(
              lat: r.lat,
              lng: r.lng,
              label: r.name,
            ),
            tapHint: 'Ouvrir dans Maps',
          ),
          const SizedBox(height: 8),

          // Horaires
          _InfoRow(
            icon: Icons.access_time_rounded,
            main: r.openingHours.isNotEmpty ? r.openingHours : 'Lun-Dim · 10h-22h',
            sub: controller.isOpen ? 'Ouvert maintenant' : 'Fermé actuellement',
            subColor: controller.isOpen ? AppColors.teal : Colors.redAccent,
          ),
          const SizedBox(height: 8),

          // Téléphone — tap ouvre l'app téléphone immédiatement
          _InfoRow(
            icon: Icons.phone_outlined,
            main: r.phone.isNotEmpty ? r.phone : '+221 XX XXX XX XX',
            sub: 'Appuyer pour appeler',
            subColor: AppColors.teal,
            onTap: r.phone.isNotEmpty
                ? () => launchPhone(r.phone)
                : null,
            tapHint: 'Appeler',
          ),
        ],
      ),
    );
  }

  // ─── Map section — tap ouvre Google Maps ──────────────────
  Widget _buildMapSection(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emplacement', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => launchGoogleMaps(
              lat: r.lat,
              lng: r.lng,
              label: r.name,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEEC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Faux terrain
                    CustomPaint(
                      size: const Size(double.infinity, 160),
                      painter: _FakeMapPainter(),
                    ),
                    // Pin central
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.white,
                              size: 22,
                            ),
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
                    // Badge distance bas gauche
                    Positioned(
                      left: 12, bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded,
                                size: 13, color: AppColors.orange),
                            const SizedBox(width: 4),
                            Text(
                              r.distanceKm != null
                                  ? r.distanceLabel
                                  : r.zone,
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Label "Ouvrir dans Google Maps" (haut droite)
                    Positioned(
                      right: 12, top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_new_rounded,
                                size: 12, color: AppColors.teal),
                            const SizedBox(width: 4),
                            Text('Google Maps',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── States ───────────────────────────────────────────────
  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('Restaurant introuvable', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.goBack,
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.white,
      child: Column(
        children: [
          Container(height: 280, color: AppColors.divider),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 28, width: 200, color: AppColors.white),
                const SizedBox(height: 12),
                Container(height: 14, width: 140, color: AppColors.white),
                const SizedBox(height: 16),
                Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────
  String _cuisineLabel(RestaurantModel r) {
    return r.tags
        .where((t) => ['senegalais', 'africain', 'fusion',
                       'fruits de mer', 'grillades'].contains(t))
        .map((t) => t[0].toUpperCase() + t.substring(1))
        .take(2)
        .join(' · ');
  }

  String _fmt(int v) {
    return v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }
}

// ─── _InfoRow avec onTap optionnel ───────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String main;
  final String? sub;
  final Color? subColor;
  final VoidCallback? onTap;
  final String? tapHint;

  const _InfoRow({
    required this.icon,
    required this.main,
    this.sub,
    this.subColor,
    this.onTap,
    this.tapHint,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: onTap != null
            ? Border.all(color: AppColors.teal.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: onTap != null ? AppColors.teal : AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(main,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    )),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subColor ?? AppColors.muted,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.teal, size: 18),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

// ─── Séparateur ──────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

// ─── Faux terrain ────────────────────────────────────────────
class _FakeMapPainter extends CustomPainter {
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

    final p2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.85,
          size.width * 0.5, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.65,
          size.width, size.height * 0.8);

    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint..color = const Color(0xFFC8D4CE));
  }

  @override
  bool shouldRepaint(_) => false;
}