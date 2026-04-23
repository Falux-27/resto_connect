import 'package:flutter/material.dart';
 

class AnimatedMascot extends StatefulWidget {
  const AnimatedMascot({super.key});

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _spriteCtrl;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  static const int _frameCount = 7;
  // 450 ms par frame → 3150 ms pour un cycle complet (3× plus lent)
  static const Duration _cycleDuration = Duration(milliseconds: 450 * _frameCount);

  @override
  void initState() {
    super.initState();

    _spriteCtrl = AnimationController(vsync: this, duration: _cycleDuration)
      ..repeat();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spriteCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spriteCtrl, _bounceAnim]),
      builder: (_, __) {
        final frame = (_spriteCtrl.value * _frameCount)
            .floor()
            .clamp(0, _frameCount - 1);

        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: Image.asset(
            'assets/images/lion_${frame + 1}.png',
            height: 90,
            fit: BoxFit.contain,
            // BlendMode.multiply × fond sable → les pixels blancs du PNG
            // deviennent identiques au fond, l'image se fond naturellement.
            color: const Color.fromARGB(255, 234, 232, 229),
            colorBlendMode: BlendMode.multiply,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 60,
              height: 90,
              child: Center(
                child: Text('🦁', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
        );
      },
    );
  }
}
