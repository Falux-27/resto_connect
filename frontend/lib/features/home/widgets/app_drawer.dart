import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../home_controller.dart';

// Mock user — remplacer par les données réelles quand l'auth sera prête.
const _mockUser = (
  initiale: 'V',
  nom: 'Visiteur JOJ',
  location: 'Plateau, Dakar · en ce moment',
  favoris: 0,
  vus: 12,
  quartiers: 3,
);

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _lang = 'FR';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: const Color(0xFFF5F6F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _langueSection(),
                _sectionLabel('Navigation'),
                _NavRow(
                  icon: Icons.search_rounded,
                  title: 'Découvrir',
                  sub: 'Explorer les restaurants',
                  onTap: () => Get.back(),
                ),
                _NavRow(
                  icon: Icons.favorite_border_rounded,
                  title: 'Favoris',
                  sub: '${_mockUser.favoris} restos sauvegardés',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.favorites);
                  },
                ),
                _NavRow(
                  icon: Icons.history_rounded,
                  title: 'Historique',
                  sub: 'Vos recherches récentes',
                  onTap: () => Get.back(),
                ),
                _NavRow(
                  icon: Icons.location_on_rounded,
                  title: 'Près des sites JOJ',
                  sub: 'Diamniadio · Stade LSS',
                  iconOrange: true,
                  onTap: () {
                    Get.back();
                    Get.find<HomeController>().onFilterCardTap('joj');
                  },
                ),
                _sectionLabel('Préférences'),
                _NavRow(
                  icon: Icons.eco_rounded,
                  title: 'Régime alimentaire',
                  sub: 'Halal, vege, sans gluten…',
                  onTap: () => Get.back(),
                ),
                _NavRow(
                  icon: Icons.credit_card_rounded,
                  title: 'Budget par défaut',
                  sub: '2 000 – 5 000 FCFA',
                  onTap: () => Get.back(),
                ),
                _NavRow(
                  icon: Icons.radar_rounded,
                  title: 'Rayon de recherche',
                  sub: '3 km à pied',
                  onTap: () => Get.back(),
                ),
                _sectionLabel('Compte'),
                _NavRow(
                  icon: Icons.auto_awesome_rounded,
                  title: 'À propos de Resto',
                  sub: 'JOJ Dakar 2026 · IA Llama',
                  onTap: () => Get.back(),
                ),
                _NavRow(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  sub: 'Nous contacter',
                  onTap: () => Get.back(),
                  isLast: true,
                ),
                _AppVersionTile(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0E4),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mockUser.nom,
                      style: AppTextStyles.h3.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.muted),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            _mockUser.location,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats cards
          Row(
            children: [
              _StatCard(value: '${_mockUser.favoris}', label: 'FAVORIS'),
              const SizedBox(width: 10),
              _StatCard(value: '${_mockUser.vus}', label: 'VUS'),
              const SizedBox(width: 10),
              _StatCard(value: '${_mockUser.quartiers}', label: 'QUARTIERS'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Langue ──────────────────────────────────────────────────────────────

  Widget _langueSection() {
    const langs = [
      ('FR', '🇫🇷'),
      ('EN', '🇬🇧'),
      ('ES', '🇪🇸'),
      ('AR', '🇸🇦'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LANGUE', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(
            children: langs.map(((String code, String flag) lang) {
              final active = lang.$1 == _lang;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _lang = lang.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? AppColors.ink : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? AppColors.ink : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(lang.$2,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          lang.$1,
                          style: AppTextStyles.label.copyWith(
                            color: active ? Colors.white : AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(text.toUpperCase(), style: AppTextStyles.label),
    );
  }
}

// ── Avatar ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          _mockUser.initiale,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ── Stat card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav row ─────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool iconOrange;
  final bool isLast;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.iconOrange = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconOrange
                        ? AppColors.orange
                        : const Color(0xFFEEF0F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconOrange ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        sub,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 74,
            endIndent: 20,
            color: AppColors.divider,
          ),
      ],
    );
  }
}

// ── App version tile ─────────────────────────────────────────────────────────

class _AppVersionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resto Connect · v1.0',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'JOJ Dakar 2026 · Sonatel / Orange',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
