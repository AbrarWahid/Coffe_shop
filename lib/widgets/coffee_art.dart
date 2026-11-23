import 'package:flutter/material.dart';

import '../data/coffee.dart';
import '../theme/app_theme.dart';

/// Illustrated stand-in for product photography: a tinted cup on a soft halo.
class CoffeeArt extends StatelessWidget {
  const CoffeeArt({
    super.key,
    required this.coffee,
    this.size = 96,
    this.hero = true,
  });

  final Coffee coffee;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color.lerp(coffee.tone, Colors.white, 0.35)!, coffee.tone],
            center: const Alignment(-0.3, -0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: coffee.tone.withValues(alpha: 0.45),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.12),
            ),
          ],
        ),
        child: Icon(
          coffee.category == CoffeeCategory.cold
              ? Icons.local_drink_rounded
              : Icons.coffee_rounded,
          size: size * 0.46,
          color: AppColors.cream.withValues(alpha: 0.95),
        ),
      ),
    );
    return hero ? Hero(tag: 'coffee-${coffee.id}', child: art) : art;
  }
}
