import 'package:flutter/material.dart';

import '../data/coffee.dart';
import '../data/order.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

abstract final class HomeTabs {
  static const menu = 0;
  static const favorites = 1;
  static const basket = 2;
  static const orders = 3;
}

/// Shows a single toast, replacing any current one.
void showToast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: AppColors.copperSoft, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: action,
      ),
    );
}

SnackBarAction _viewBasketAction(NavigatorState navigator, AppState state) =>
    SnackBarAction(
      label: 'View basket',
      onPressed: () {
        navigator.popUntil((route) => route.isFirst);
        state.selectTab(HomeTabs.basket);
      },
    );

/// Copies a past order into the basket and says what happened.
void reorderWithFeedback(BuildContext context, Order order) {
  final state = AppScope.read(context);
  final navigator = Navigator.of(context);
  final unavailable = state.reorder(order);
  final added = order.lines.length - unavailable;
  if (added == 0) {
    showToast(
      context,
      'Those drinks are no longer on the menu.',
      icon: Icons.info_outline_rounded,
    );
    return;
  }
  final note = unavailable > 0 ? ' ($unavailable no longer available)' : '';
  showToast(
    context,
    'Added ${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} to your basket$note',
    action: _viewBasketAction(navigator, state),
  );
}

/// Adds to the basket and confirms it, with a shortcut to the basket tab.
/// Explains when the per-item limit stops the add.
void addToBasketWithFeedback(
  BuildContext context,
  Coffee coffee, {
  CupSize size = CupSize.regular,
  int quantity = 1,
}) {
  // Capture everything up front: the caller may pop its route right after.
  final state = AppScope.read(context);
  final navigator = Navigator.of(context);
  final added = state.add(coffee, size: size, quantity: quantity);
  if (added == 0) {
    showToast(
      context,
      'You already have the maximum of ${AppState.maxQuantity} ${coffee.name} (${size.label}).',
      icon: Icons.info_outline_rounded,
    );
    return;
  }
  final capped = added < quantity
      ? ' (limit ${AppState.maxQuantity} per item)'
      : '';
  showToast(
    context,
    '$added× ${coffee.name} (${size.label}) added$capped',
    action: _viewBasketAction(navigator, state),
  );
}
