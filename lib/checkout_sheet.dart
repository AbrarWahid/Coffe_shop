import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'basket_page.dart';
import 'data/order.dart';
import 'orders_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/format.dart';
import 'utils/validators.dart';
import 'widgets/app_button.dart';
import 'widgets/app_text_field.dart';
import 'widgets/feedback.dart';
import 'widgets/inline_message.dart';
import 'widgets/pressable.dart';

/// Opens checkout; on success shows the confirmation dialog.
Future<void> showCheckout(BuildContext context) async {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final order = await showModalBottomSheet<Order>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => const CheckoutSheet(),
  );
  if (order != null && context.mounted) await _showConfirmation(context, order);
}

Future<void> _showConfirmation(BuildContext context, Order order) {
  final state = AppScope.read(context);
  final navigator = Navigator.of(context);
  final pickup = order.fulfilment == Fulfilment.pickup;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.slow * 1.5,
                curve: Curves.elasticOut,
                builder: (context, t, child) =>
                    Transform.scale(scale: t, child: child),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Order placed', style: AppText.display(26)),
              const SizedBox(height: 4),
              Text(order.id, style: AppText.body(13, color: AppColors.muted)),
              const SizedBox(height: 12),
              Text(
                pickup
                    ? 'We\'ll have it ready at the counter in about 10 minutes. '
                          'Pay with ${order.payment.label} when you collect.'
                    : 'Our baristas are on it. Expect your coffee in about 25 minutes. '
                          'Pay ${formatRupiah(order.total)} with ${order.payment.label} on delivery.',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Track order',
                onPressed: () {
                  Navigator.pop(dialogContext);
                  state.selectTab(HomeTabs.orders);
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPage(orderId: order.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  state.selectTab(HomeTabs.menu);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                child: const Text('Back to menu'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({super.key});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  late final AppState _state = AppScope.read(context);
  // Prefill from the last order so repeat customers just confirm.
  late final _address = TextEditingController(
    text: _state.deliveryProfile.address,
  );
  late final _phone = TextEditingController(text: _state.deliveryProfile.phone);
  final _note = TextEditingController();
  Fulfilment _fulfilment = Fulfilment.delivery;
  PaymentMethod _payment = PaymentMethod.cash;
  bool _remember = true;
  bool _placing = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = 'Please check the highlighted fields.');
      return;
    }
    setState(() => _placing = true);
    try {
      final order = await _state.placeOrder(
        CheckoutDetails(
          fulfilment: _fulfilment,
          payment: _payment,
          address: _address.text,
          phone: _phone.text,
          note: _note.text,
          remember: _remember,
        ),
      );
      if (mounted) Navigator.pop(context, order);
    } on Object catch (e) {
      // Keep the sheet open with the user's input so they can retry.
      if (mounted) {
        setState(() {
          _placing = false;
          _error =
              'We couldn\'t place your order. ${e is StateError ? e.message : 'Please try again.'}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final delivery = _fulfilment == Fulfilment.delivery;
    final hasSaved = !state.deliveryProfile.isEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Checkout', style: AppText.display(26))),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _placing ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              if (hasSaved)
                Text(
                  'We filled in your details from last time.',
                  style: AppText.body(13, color: AppColors.muted),
                ),
              const SizedBox(height: 16),
              InlineMessage(message: _error),
              const SizedBox(height: 8),
              _Label('How would you like it?'),
              Row(
                children: [
                  for (final f in Fulfilment.values) ...[
                    Expanded(
                      child: _ChoiceTile(
                        icon: f == Fulfilment.delivery
                            ? Icons.delivery_dining_rounded
                            : Icons.storefront_rounded,
                        title: f.label,
                        caption: f == Fulfilment.delivery
                            ? (state.deliveryFor(f) == 0
                                  ? 'Free for this order'
                                  : '${formatRupiah(state.deliveryFor(f))} fee')
                            : 'Ready in ~10 min',
                        selected: _fulfilment == f,
                        onTap: () => setState(() => _fulfilment = f),
                      ),
                    ),
                    if (f != Fulfilment.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: AppMotion.curve,
                alignment: Alignment.topCenter,
                child: delivery
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppTextField(
                          label: 'Delivery address',
                          controller: _address,
                          hint: 'Street, number, building, unit',
                          icon: Icons.location_on_outlined,
                          keyboardType: TextInputType.streetAddress,
                          autofillHints: const [
                            AutofillHints.fullStreetAddress,
                          ],
                          validator: Validators.address,
                          maxLines: 2,
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              AppTextField(
                label: delivery
                    ? 'Phone for the courier'
                    : 'Phone, in case we need you',
                controller: _phone,
                hint: '0812 3456 7890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ \-]')),
                ],
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Note (optional)',
                controller: _note,
                hint: delivery
                    ? 'e.g. less sugar, leave at the gate'
                    : 'e.g. less ice',
                icon: Icons.edit_note_rounded,
                textInputAction: TextInputAction.done,
                inputFormatters: [LengthLimitingTextInputFormatter(140)],
              ),
              CheckboxListTile(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? true),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.copper,
                dense: true,
                title: Text(
                  'Remember these details for next time',
                  style: AppText.body(13, weight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              _Label(delivery ? 'Pay on delivery with' : 'Pay at pickup with'),
              Row(
                children: [
                  for (final p in PaymentMethod.values) ...[
                    Expanded(
                      child: _ChoiceTile(
                        icon: p == PaymentMethod.cash
                            ? Icons.payments_outlined
                            : Icons.qr_code_2_rounded,
                        title: p.label,
                        caption: p == PaymentMethod.cash
                            ? 'Exact change helps'
                            : 'Any e-wallet',
                        selected: _payment == p,
                        onTap: () => setState(() => _payment = p),
                      ),
                    ),
                    if (p != PaymentMethod.values.last)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              OrderSummary(
                subtotal: state.subtotal,
                delivery: state.deliveryFor(_fulfilment),
                deliveryLabel: delivery ? 'Delivery' : 'Pickup',
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Place order',
                loading: _placing,
                onPressed: _placeOrder,
                trailing: Text(
                  formatRupiah(state.totalFor(_fulfilment)),
                  style: AppText.body(
                    15,
                    weight: FontWeight.w700,
                    color: AppColors.copperSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppText.body(13, weight: FontWeight.w600)),
  );
}

/// Selectable card used for fulfilment and payment choices.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        semanticLabel: title,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.curve,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.copperSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.copper : AppColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.copperDeep : AppColors.ink,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body(14, weight: FontWeight.w700),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
