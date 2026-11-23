import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label, {this.badge = 0});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
}

/// Floating bottom navigation with an expanding pill on the active item.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<NavItem> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // On very narrow phones the active pill shows only its icon.
    final showLabel = MediaQuery.sizeOf(context).width >= 360;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Center(
        heightFactor: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: AppColors.espresso,
            borderRadius: BorderRadius.circular(100),
            boxShadow: AppShadows.lifted,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavButton(
                  item: items[i],
                  active: i == selected,
                  showLabel: showLabel,
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.showLabel,
    required this.onTap,
  });

  final NavItem item;
  final bool showLabel;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: item.label,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: item.badge > 0,
              backgroundColor: AppColors.copper,
              label: AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text('${item.badge}', key: ValueKey(item.badge)),
              ),
              child: Icon(
                active ? item.activeIcon : item.icon,
                size: 22,
                color: active
                    ? AppColors.espresso
                    : AppColors.cream.withValues(alpha: 0.7),
              ),
            ),
            AnimatedSize(
              duration: AppMotion.medium,
              curve: AppMotion.curve,
              child: active && showLabel
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: AppText.body(13, weight: FontWeight.w700),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
