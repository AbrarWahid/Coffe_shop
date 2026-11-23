import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

enum AppButtonVariant { primary, accent, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool loading;
  final bool expand;

  /// Optional widget on the right edge, e.g. an animated price.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (AppColors.espresso, AppColors.cream, null),
      AppButtonVariant.accent => (AppColors.copper, AppColors.surface, null),
      AppButtonVariant.outline => (
        AppColors.surface,
        AppColors.ink,
        Border.all(color: AppColors.line),
      ),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: trailing == null
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 18),
                  child: icon!,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(15, weight: FontWeight.w700, color: fg),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );

    return Pressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: onPressed == null ? 0.45 : 1,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.curve,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: bg,
            border: border,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: variant == AppButtonVariant.outline || !enabled
                ? null
                : [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.medium,
            child: loading
                ? Center(
                    key: const ValueKey('loading'),
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: fg,
                      ),
                    ),
                  )
                : KeyedSubtree(key: const ValueKey('content'), child: content),
          ),
        ),
      ),
    );
  }
}

/// Round icon button used for back / favourite / utility actions.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.background = AppColors.surface,
    this.foreground = AppColors.ink,
    this.size = 44,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        scale: 0.9,
        semanticLabel: tooltip,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: background == AppColors.surface ? AppShadows.soft : null,
          ),
          child: IconTheme(
            data: IconThemeData(color: foreground, size: 20),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
