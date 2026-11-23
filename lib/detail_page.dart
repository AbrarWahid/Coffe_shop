import 'package:flutter/material.dart';

import 'data/coffee.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/format.dart';
import 'widgets/app_button.dart';
import 'widgets/coffee_art.dart';
import 'widgets/fade_slide_in.dart';
import 'widgets/favorite_button.dart';
import 'widgets/feedback.dart';
import 'widgets/pressable.dart';
import 'widgets/quantity_stepper.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.coffee});

  final Coffee coffee;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _quantity = 1;
  CupSize _size = CupSize.regular;

  Coffee get coffee => widget.coffee;
  int get _total => coffee.priceFor(_size) * _quantity;

  void _addToBasket() {
    addToBasketWithFeedback(context, coffee, size: _size, quantity: _quantity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final art = _ArtPanel(
      coffee: coffee,
      favorite: state.isFavorite(coffee),
      onFavorite: () => state.toggleFavorite(coffee),
    );

    final bar = _BottomBar(
      quantity: _quantity,
      total: _total,
      onQuantity: (q) => setState(() => _quantity = q),
      onAdd: _addToBasket,
    );
    final wide = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      body: wide
          // Wide: artwork left, details + purchase bar in the right column.
          ? Row(
              children: [
                Expanded(child: art),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SafeArea(
                          bottom: false,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                40,
                                40,
                                40,
                                24,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: _details(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      bar,
                    ],
                  ),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 360, child: art)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  sliver: SliverToBoxAdapter(child: _details()),
                ),
              ],
            ),
      bottomNavigationBar: wide ? null : bar,
    );
  }

  Widget _details() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coffee.category.label.toUpperCase(),
            style: AppText.overline(color: AppColors.copperDeep),
          ),
          const SizedBox(height: 8),
          Text(coffee.name, style: AppText.display(34)),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.copper),
              const SizedBox(width: 4),
              Text(
                coffee.rating.toStringAsFixed(1),
                style: AppText.body(14, weight: FontWeight.w700),
              ),
              _dot(),
              Text(
                coffee.tagline,
                style: AppText.body(14, color: AppColors.muted),
              ),
              _dot(),
              Text(
                formatRupiah(coffee.price),
                style: AppText.body(14, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Choose a size'),
          Row(
            children: [
              for (final size in CupSize.values) ...[
                Expanded(
                  child: _SizeOption(
                    size: size,
                    selected: size == _size,
                    onTap: () => setState(() => _size = size),
                  ),
                ),
                if (size != CupSize.values.last) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('In every cup'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ingredient in coffee.ingredients)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    ingredient,
                    style: AppText.body(13, weight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('About'),
          Text(
            coffee.description,
            style: AppText.body(15, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('·', style: AppText.body(14, color: AppColors.muted)),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: AppText.body(15, weight: FontWeight.w700)),
  );
}

class _ArtPanel extends StatelessWidget {
  const _ArtPanel({
    required this.coffee,
    required this.favorite,
    required this.onFavorite,
  });

  final Coffee coffee;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            coffee.tone.withValues(alpha: 0.35),
            coffee.tone.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(child: CoffeeArt(coffee: coffee, size: 200)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FavoriteButton(active: favorite, onTap: onFavorite),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final CupSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final delta = size.priceDelta;
    final fg = selected ? AppColors.cream : AppColors.ink;
    return Pressable(
      onTap: onTap,
      semanticLabel: '${size.label} size',
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 28,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Icon(
                  Icons.coffee_rounded,
                  size: 16.0 + size.index * 5,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              size.label,
              style: AppText.body(13, weight: FontWeight.w700, color: fg),
            ),
            Text(
              delta == 0
                  ? 'Standard'
                  : '${delta > 0 ? '+' : '−'}${formatRupiah(delta.abs())}',
              style: AppText.body(
                11,
                color: selected
                    ? AppColors.cream.withValues(alpha: 0.7)
                    : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.quantity,
    required this.total,
    required this.onQuantity,
    required this.onAdd,
  });

  final int quantity;
  final int total;
  final ValueChanged<int> onQuantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: AppText.body(12, color: AppColors.muted),
                        ),
                        AnimatedSwitcher(
                          duration: AppMotion.medium,
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previous, ?current],
                          ),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween(
                                begin: const Offset(0, 0.4),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: FittedBox(
                            key: ValueKey(total),
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatRupiah(total),
                              style: AppText.display(22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  QuantityStepper(
                    value: quantity,
                    onChanged: onQuantity,
                    max: AppState.maxQuantity,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Add to basket',
                icon: const Icon(Icons.add_shopping_cart_rounded),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
