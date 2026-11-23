import 'package:flutter/material.dart';

import '../data/coffee.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'coffee_art.dart';
import 'favorite_button.dart';
import 'pressable.dart';

class CoffeeCard extends StatelessWidget {
  const CoffeeCard({
    super.key,
    required this.coffee,
    required this.onOpen,
    required this.onQuickAdd,
    this.hero = true,
  });

  final Coffee coffee;
  final VoidCallback onOpen;
  final VoidCallback onQuickAdd;

  /// Hero tags must be unique per route; disable when the coffee may appear twice.
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Pressable(
      onTap: onOpen,
      scale: 0.97,
      semanticLabel: coffee.name,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: coffee.tone.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: LayoutBuilder(
                        builder: (context, c) => CoffeeArt(
                          coffee: coffee,
                          size: c.maxHeight * 0.62,
                          hero: hero,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(
                        active: state.isFavorite(coffee),
                        onTap: () => state.toggleFavorite(coffee),
                        size: 34,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 8,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.copper,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            coffee.rating.toStringAsFixed(1),
                            style: AppText.body(11, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coffee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coffee.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatRupiah(coffee.price),
                          style: AppText.body(14, weight: FontWeight.w700),
                        ),
                      ),
                      Pressable(
                        onTap: onQuickAdd,
                        scale: 0.85,
                        semanticLabel: 'Add ${coffee.name} to basket',
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.espresso,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.cream,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
