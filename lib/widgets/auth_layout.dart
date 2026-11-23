import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_mark.dart';
import 'fade_slide_in.dart';

/// Shared shell for login & register: a dark espresso brand panel and a
/// cream form sheet. Stacks vertically on phones, splits side by side on wide screens.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final hero = _BrandPanel(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            showBack: showBack,
            wide: wide,
          );
          final form = _FormSheet(wide: wide, child: child);

          if (wide) {
            return Row(
              children: [
                Expanded(flex: 5, child: hero),
                Expanded(flex: 6, child: form),
              ],
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: hero),
              SliverToBoxAdapter(child: form),
              // Extends the cream sheet to the bottom on tall screens.
              const SliverFillRemaining(
                hasScrollBody: false,
                child: ColoredBox(color: AppColors.cream),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.showBack,
    required this.wide,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final bool showBack;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative rings evoke a cup seen from above.
        Positioned(
          right: -80,
          top: -60,
          child: _Ring(size: 260, opacity: 0.18),
        ),
        Positioned(right: -20, top: 0, child: _Ring(size: 150, opacity: 0.12)),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 20, 28, wide ? 48 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (showBack) ...[
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    const Flexible(child: BrandMark(light: true)),
                  ],
                ),
                if (wide) const Spacer() else const SizedBox(height: 40),
                FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow.toUpperCase(), style: AppText.overline()),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: AppText.display(
                          wide ? 44 : 32,
                          color: AppColors.cream,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Text(
                          subtitle,
                          style: AppText.body(
                            14,
                            color: AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (wide) const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.copper.withValues(alpha: opacity),
        width: 24,
      ),
    ),
  );
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({required this.wide, required this.child});

  final bool wide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Align(
        alignment: wide ? Alignment.center : Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: child,
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: wide
            ? null
            : const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      // On narrow screens the whole page scrolls (see AuthLayout), so only
      // the wide layout needs its own scroll view.
      child: SafeArea(
        top: wide,
        child: wide
            ? Center(child: SingleChildScrollView(child: content))
            : content,
      ),
    );
  }
}
