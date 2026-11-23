import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Monogram + wordmark used across auth screens.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light ? AppColors.cream : AppColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.copper, width: 1.4),
          ),
          child: const Icon(
            Icons.coffee_maker_outlined,
            color: AppColors.copper,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coffee Shop',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(18, color: fg),
              ),
              Text(
                'ROASTED DAILY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.overline().copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
