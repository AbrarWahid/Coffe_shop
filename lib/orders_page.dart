import 'package:flutter/material.dart';

import 'basket_page.dart';
import 'data/coffee.dart';
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
import 'widgets/live_clock.dart';

String formatOrderTime(DateTime time, DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  final clock = '${two(time.hour)}:${two(time.minute)}';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  if (day == today) return 'Today, $clock';
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $clock';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${time.day} ${months[time.month - 1]}, $clock';
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final orders = state.orders;
    return SafeArea(
      bottom: false,
      child: PageFrame(
        maxWidth: 640,
        child: LiveClock(
          builder: (context, now) {
            final active = orders
                .where((o) => o.statusAt(now) != OrderStatus.completed)
                .toList();
            final past = orders
                .where((o) => o.statusAt(now) == OrderStatus.completed)
                .toList();
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orders', style: AppText.display(30)),
                        const SizedBox(height: 4),
                        Text(
                          'Track what\'s brewing and reorder past favourites.',
                          style: AppText.body(14, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                if (orders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      message:
                          'When you place an order you can follow it here.',
                      actionLabel: 'Browse the menu',
                      onAction: () => state.selectTab(HomeTabs.menu),
                    ),
                  )
                else ...[
                  if (active.isNotEmpty) _section('In progress', active, now),
                  if (past.isNotEmpty) _section('Past orders', past, now),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(height: navBarClearance(context) + 24),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(String title, List<Order> orders, DateTime now) =>
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        sliver: SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                title,
                style: AppText.body(15, weight: FontWeight.w700),
              ),
            ),
            for (final (i, order) in orders.indexed)
              FadeSlideIn(
                key: ValueKey(order.id),
                delay: Duration(milliseconds: 40 * (i % 6)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OrderCard(order: order, now: now),
                ),
              ),
          ],
        ),
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final status = order.statusAt(now);
    final first = coffeeById(order.lines.first.coffeeId);
    return Pressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id)),
      ),
      scale: 0.98,
      semanticLabel: 'Order ${order.id}, ${status.label}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (first != null) ...[
                  CoffeeArt(coffee: first, size: 44, hero: false),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.lines
                            .map((l) => '${l.quantity}× ${l.name}')
                            .join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(14, weight: FontWeight.w700),
                      ),
                      Text(
                        '${formatOrderTime(order.placedAt, now)} · ${order.fulfilment.label}',
                        style: AppText.body(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(status: status),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatRupiah(order.total),
                  style: AppText.body(15, weight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final done = status == OrderStatus.completed;
    final color = done ? AppColors.success : AppColors.copperDeep;
    return AnimatedContainer(
      duration: AppMotion.medium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.copperSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_rounded : Icons.timelapse_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(12, weight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: Text(
          order?.id ?? 'Order',
          style: AppText.body(16, weight: FontWeight.w700),
        ),
      ),
      body: order == null
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Order not found',
              message: 'It may belong to another account.',
            )
          : LiveClock(
              builder: (context, now) => PageFrame(
                maxWidth: 640,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Tracker(order: order, now: now),
                      const SizedBox(height: 24),
                      Text(
                        'Items',
                        style: AppText.body(15, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      for (final line in order.lines)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                '${line.quantity}×',
                                style: AppText.body(
                                  14,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${line.name} · ${line.size.label}',
                                  style: AppText.body(14),
                                ),
                              ),
                              Text(
                                formatRupiah(line.total),
                                style: AppText.body(
                                  14,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      OrderSummary(
                        subtotal: order.subtotal,
                        delivery: order.deliveryFee,
                        deliveryLabel: order.fulfilment == Fulfilment.delivery
                            ? 'Delivery'
                            : 'Pickup',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Details',
                        style: AppText.body(15, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        Icons.schedule_rounded,
                        'Placed',
                        formatOrderTime(order.placedAt, now),
                      ),
                      _DetailRow(
                        order.fulfilment == Fulfilment.delivery
                            ? Icons.delivery_dining_rounded
                            : Icons.storefront_rounded,
                        order.fulfilment.label,
                        order.address ?? 'Collect at the counter',
                      ),
                      if (order.phone != null)
                        _DetailRow(Icons.phone_outlined, 'Phone', order.phone!),
                      _DetailRow(
                        Icons.payments_outlined,
                        'Payment',
                        '${order.payment.label} on ${order.fulfilment == Fulfilment.delivery ? 'delivery' : 'pickup'}',
                      ),
                      if (order.note != null)
                        _DetailRow(
                          Icons.edit_note_rounded,
                          'Note',
                          order.note!,
                        ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Order again',
                        icon: const Icon(Icons.replay_rounded),
                        onPressed: () => reorderWithFeedback(context, order),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.muted),
        const SizedBox(width: 12),
        SizedBox(
          width: 84,
          child: Text(label, style: AppText.body(14, color: AppColors.muted)),
        ),
        Expanded(
          child: Text(value, style: AppText.body(14, weight: FontWeight.w500)),
        ),
      ],
    ),
  );
}

/// Vertical progress tracker for the order's steps.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.order, required this.now});

  final Order order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final status = order.statusAt(now);
    final current = order.steps.indexOf(status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(status.label, style: AppText.display(24)),
          const SizedBox(height: 4),
          Text(
            status == OrderStatus.completed
                ? 'Enjoy your coffee!'
                : 'Status updates automatically.',
            style: AppText.body(13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          for (final (i, step) in order.steps.indexed)
            Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.medium,
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current ? AppColors.copper : AppColors.sand,
                  ),
                  child: i < current || status == OrderStatus.completed
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.label,
                    style: AppText.body(
                      14,
                      weight: i == current ? FontWeight.w700 : FontWeight.w500,
                      color: i <= current ? AppColors.ink : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
