import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonSize = compact ? 30.0 : 40.0;
    Widget button(IconData icon, String label, int next, bool enabled) =>
        Pressable(
          onTap: enabled ? () => onChanged(next) : null,
          scale: 0.88,
          semanticLabel: label,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.sand,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: compact ? 16 : 18,
              color: enabled ? AppColors.ink : AppColors.muted,
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            Icons.remove_rounded,
            'Decrease quantity',
            value - 1,
            value > min,
          ),
          SizedBox(
            width: compact ? 30 : 40,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppText.body(compact ? 14 : 16, weight: FontWeight.w700),
              ),
            ),
          ),
          button(
            Icons.add_rounded,
            'Increase quantity',
            value + 1,
            value < max,
          ),
        ],
      ),
    );
  }
}
