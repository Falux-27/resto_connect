import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AiHintBanner extends StatefulWidget {
  final VoidCallback? onTap;
  const AiHintBanner({super.key, this.onTap});

  @override
  State<AiHintBanner> createState() => _AiHintBannerState();
}

class _AiHintBannerState extends State<AiHintBanner>
    with TickerProviderStateMixin {
  late final AnimationController _pulse1;
  late final AnimationController _pulse2;
  late final AnimationController _pulse3;

  @override
  void initState() {
    super.initState();
    _pulse1 = _makeCtrl(0);
    _pulse2 = _makeCtrl(400);
    _pulse3 = _makeCtrl(800);
  }

  AnimationController _makeCtrl(int delayMs) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) ctrl.repeat();
    });
    return ctrl;
  }

  @override
  void dispose() {
    _pulse1.dispose();
    _pulse2.dispose();
    _pulse3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(controller: _pulse1, maxScale: 2.0),
              _PulseRing(controller: _pulse2, maxScale: 2.0),
              _PulseRing(controller: _pulse3, maxScale: 2.0),
              // Core button
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double maxScale;

  const _PulseRing({required this.controller, required this.maxScale});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final scale = 1.0 + (maxScale - 1.0) * controller.value;
        final opacity = (1.0 - controller.value).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.orange.withValues(alpha: opacity * 0.5),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
