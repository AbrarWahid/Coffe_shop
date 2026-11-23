import 'package:flutter/material.dart';

import 'data/order.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/format.dart';
import 'widgets/app_button.dart';
import 'widgets/feedback.dart';
import 'widgets/page_frame.dart';

/// Lightweight personal stats derived from order history.
class CoffeeStats {
  CoffeeStats(List<Order> orders)
    : orderCount = orders.length,
      cups = orders.fold(0, (sum, o) => sum + o.itemCount),
      spent = orders.fold(0, (sum, o) => sum + o.total),
      favourite = _favourite(orders);

  final int orderCount;
  final int cups;
  final int spent;
  final String? favourite;

  static String? _favourite(List<Order> orders) {
    final counts = <String, int>{};
    for (final line in orders.expand((o) => o.lines)) {
      counts.update(
        line.name,
        (c) => c + line.quantity,
        ifAbsent: () => line.quantity,
      );
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final state = AppScope.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Sign out?', style: AppText.display(22)),
        content: Text(
          state.itemCount > 0
              ? 'Your basket is saved and will be here when you sign back in.'
              : 'You can sign back in at any time.',
          style: AppText.body(14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    // The app root returns to the sign-in screen on its own.
    if (confirmed == true) await state.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final account = state.account;
    if (account == null) return const SizedBox.shrink();
    final stats = CoffeeStats(state.orders);
    final profile = state.deliveryProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Account',
          style: AppText.body(16, weight: FontWeight.w700),
        ),
      ),
      body: PageFrame(
        maxWidth: 640,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.copperSoft,
                  child: Text(
                    state.userName.characters.first,
                    style: AppText.display(26, color: AppColors.copperDeep),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.userName, style: AppText.display(24)),
                      Text(
                        account.email,
                        style: AppText.body(14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Your coffee',
              style: AppText.body(15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(label: 'Orders', value: '${stats.orderCount}'),
                const SizedBox(width: 10),
                _Stat(label: 'Cups', value: '${stats.cups}'),
                const SizedBox(width: 10),
                _Stat(label: 'Spent', value: formatRupiah(stats.spent)),
              ],
            ),
            if (stats.favourite != null) ...[
              const SizedBox(height: 10),
              _Tile(
                icon: Icons.local_cafe_rounded,
                title: 'Most ordered',
                subtitle: stats.favourite!,
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Saved delivery details',
              style: AppText.body(15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (profile.isEmpty)
              const _Tile(
                icon: Icons.location_off_outlined,
                title: 'Nothing saved',
                subtitle:
                    'Your address and phone are saved when you check out.',
              )
            else
              _Tile(
                icon: Icons.location_on_outlined,
                title: profile.address.isEmpty
                    ? 'Pickup only'
                    : profile.address,
                subtitle: profile.phone,
                trailing: TextButton(
                  onPressed: () {
                    state.forgetDeliveryProfile();
                    showToast(
                      context,
                      'Saved delivery details removed',
                      icon: Icons.delete_outline_rounded,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  child: const Text('Forget'),
                ),
              ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Sign out',
              variant: AppButtonVariant.outline,
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _signOut(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Your data is stored on this device only.',
              textAlign: TextAlign.center,
              style: AppText.body(12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display(20)),
          ),
          Text(label, style: AppText.body(12, color: AppColors.muted)),
        ],
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.copperDeep),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.body(14, weight: FontWeight.w600)),
              Text(subtitle, style: AppText.body(12, color: AppColors.muted)),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
