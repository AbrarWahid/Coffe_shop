import 'package:flutter/material.dart';

import 'checkout_sheet.dart';
import 'data/order.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/format.dart';
import 'widgets/app_button.dart';
import 'widgets/coffee_art.dart';
import 'widgets/empty_state.dart';
import 'widgets/fade_slide_in.dart';
import 'widgets/feedback.dart';
import 'widgets/page_frame.dart';
import 'widgets/pressable.dart';
import 'widgets/quantity_stepper.dart';

/// Basket tab: editable order lines, a price summary and checkout.
class BasketPage extends StatelessWidget {
  const BasketPage({super.key});

  void _remove(BuildContext context, CartLine line) {
    final state = AppScope.read(context);
    state.remove(line);
    showToast(
      context,
      '${line.coffee.name} removed',
      icon: Icons.delete_outline_rounded,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => state.restore(line),
      ),
    );
  }

  Future<void> _clear(BuildContext context) async {
    final state = AppScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Empty your basket?', style: AppText.display(22)),
        content: Text(
          'All ${state.itemCount} items will be removed.',
          style: AppText.body(14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Empty basket'),
          ),
        ],
      ),
    );
    if (confirmed == true) state.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final lines = state.cart;

    return SafeArea(
      bottom: false,
      child: PageFrame(
        maxWidth: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your basket', style: AppText.display(30)),
                        if (lines.isNotEmpty)
                          Text(
                            '${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
                            style: AppText.body(13, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                  if (lines.isNotEmpty)
                    TextButton(
                      onPressed: () => _clear(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.muted,
                      ),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                child: lines.isEmpty
                    ? EmptyState(
                        key: const ValueKey('empty'),
                        icon: Icons.shopping_bag_outlined,
                        title: 'Your basket is empty',
                        message: state.orders.isEmpty
                            ? 'Pick something warm from the menu to get started.'
                            : 'Pick something new, or repeat a past order from the Orders tab.',
                        actionLabel: 'Browse the menu',
                        onAction: () => state.selectTab(HomeTabs.menu),
                      )
                    : ListView(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        children: [
                          _FreeDeliveryProgress(
                            remaining: state.untilFreeDelivery,
                          ),
                          const SizedBox(height: 12),
                          for (final (i, line) in lines.indexed)
                            FadeSlideIn(
                              key: ValueKey(line.key),
                              delay: Duration(milliseconds: 40 * i),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Dismissible(
                                  key: ValueKey('dismiss-${line.key}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _remove(context, line),
                                  background: const _DismissBackground(),
                                  child: _BasketLine(
                                    line: line,
                                    onQuantity: (q) =>
                                        state.setQuantity(line, q),
                                    onRemove: () => _remove(context, line),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Tip: swipe an item left to remove it.',
                            textAlign: TextAlign.center,
                            style: AppText.body(12, color: AppColors.muted),
                          ),
                          const SizedBox(height: 20),
                          OrderSummary(
                            subtotal: state.subtotal,
                            delivery: state.deliveryFor(Fulfilment.delivery),
                            deliveryCaption: 'Pickup is always free',
                          ),
                        ],
                      ),
              ),
            ),
            // Checkout stays pinned just above the floating nav bar.
            AnimatedSize(
              duration: AppMotion.medium,
              curve: AppMotion.curve,
              child: lines.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        12,
                        24,
                        navBarClearance(context),
                      ),
                      child: AppButton(
                        label: 'Checkout',
                        onPressed: () => showCheckout(context),
                        trailing: Text(
                          // Matches the summary's total (delivery estimate).
                          formatRupiah(state.totalFor(Fulfilment.delivery)),
                          style: AppText.body(
                            15,
                            weight: FontWeight.w700,
                            color: AppColors.copperSoft,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nudges toward the free-delivery threshold with a progress bar.
class _FreeDeliveryProgress extends StatelessWidget {
  const _FreeDeliveryProgress({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final unlocked = remaining == 0;
    final progress = 1 - remaining / Pricing.freeDeliveryThreshold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.copperSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked
                    ? Icons.check_circle_rounded
                    : Icons.delivery_dining_rounded,
                size: 18,
                color: unlocked ? AppColors.success : AppColors.copperDeep,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unlocked
                      ? 'You\'ve unlocked free delivery'
                      : 'Add ${formatRupiah(remaining)} more for free delivery',
                  style: AppText.body(
                    13,
                    weight: FontWeight.w600,
                    color: unlocked ? AppColors.success : AppColors.copperDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress.clamp(0.0, 1.0)),
              duration: AppMotion.slow,
              curve: AppMotion.curve,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.surface,
                color: unlocked ? AppColors.success : AppColors.copper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: AppColors.danger,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
  );
}

class _BasketLine extends StatelessWidget {
  const _BasketLine({
    required this.line,
    required this.onQuantity,
    required this.onRemove,
  });

  final CartLine line;
  final ValueChanged<int> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: line.coffee.tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: CoffeeArt(coffee: line.coffee, size: 48, hero: false),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.coffee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(16),
                      ),
                    ),
                    Pressable(
                      onTap: onRemove,
                      scale: 0.85,
                      semanticLabel: 'Remove ${line.coffee.name}',
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${line.size.label} · ${formatRupiah(line.unitPrice)}',
                  style: AppText.body(12, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    QuantityStepper(
                      value: line.quantity,
                      onChanged: onQuantity,
                      max: AppState.maxQuantity,
                      compact: true,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppMotion.fast,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerRight,
                          children: [...previous, ?current],
                        ),
                        child: FittedBox(
                          key: ValueKey(line.total),
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatRupiah(line.total),
                            style: AppText.body(15, weight: FontWeight.w700),
                          ),
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
    );
  }
}

/// Receipt-style price breakdown shared by basket, checkout and order detail.
class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.delivery,
    this.deliveryLabel = 'Delivery',
    this.deliveryCaption,
  });

  final int subtotal;
  final int delivery;
  final String deliveryLabel;
  final String? deliveryCaption;

  @override
  Widget build(BuildContext context) {
    Widget row(
      String label,
      String value, {
      bool strong = false,
      String? caption,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: strong
                      ? AppText.body(15, weight: FontWeight.w700)
                      : AppText.body(14, color: AppColors.muted),
                ),
                if (caption != null)
                  Text(
                    caption,
                    style: AppText.body(11, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: strong
                ? AppText.display(20)
                : AppText.body(14, weight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          row('Subtotal', formatRupiah(subtotal)),
          row(
            deliveryLabel,
            delivery == 0 ? 'Free' : formatRupiah(delivery),
            caption: deliveryCaption,
          ),
          const Divider(color: AppColors.line, height: 20),
          row('Total', formatRupiah(subtotal + delivery), strong: true),
        ],
      ),
    );
  }
}
