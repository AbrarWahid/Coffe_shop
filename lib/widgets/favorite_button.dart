import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

/// Heart toggle with a small "pop" when it becomes active.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.active,
    required this.onTap,
    this.size = 44,
  });

  final bool active;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.85,
      semanticLabel: active ? 'Remove from favourites' : 'Add to favourites',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.medium,
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: child,
          ),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(active),
            size: size * 0.5,
            color: active ? AppColors.danger : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
