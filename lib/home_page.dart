import 'package:flutter/material.dart';

import 'account_page.dart';
import 'basket_page.dart';
import 'data/coffee.dart';
import 'data/menu_query.dart';
import 'data/order.dart';
import 'detail_page.dart';
import 'orders_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'utils/format.dart';
import 'widgets/app_button.dart';
import 'widgets/coffee_art.dart';
import 'widgets/coffee_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/fade_slide_in.dart';
import 'widgets/feedback.dart';
import 'widgets/nav_bar.dart';
import 'widgets/page_frame.dart';
import 'widgets/live_clock.dart';
import 'widgets/pressable.dart';

/// Signed-in shell: Menu, Saved, Basket and Orders behind a floating nav bar.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: state.tab,
        children: const [
          _MenuTab(),
          _FavoritesTab(),
          BasketPage(),
          OrdersPage(),
        ],
      ),
      bottomNavigationBar: LiveClock(
        builder: (context, now) => AppNavBar(
          selected: state.tab,
          onSelected: (tab) {
            // Don't let a stale toast cover the next tab's actions.
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            state.selectTab(tab);
          },
          items: [
            const NavItem(
              Icons.local_cafe_outlined,
              Icons.local_cafe_rounded,
              'Menu',
            ),
            const NavItem(
              Icons.favorite_border_rounded,
              Icons.favorite_rounded,
              'Saved',
            ),
            NavItem(
              Icons.shopping_bag_outlined,
              Icons.shopping_bag_rounded,
              'Basket',
              badge: state.itemCount,
            ),
            NavItem(
              Icons.receipt_long_outlined,
              Icons.receipt_long_rounded,
              'Orders',
              badge: state.orders
                  .where((o) => o.statusAt(now) != OrderStatus.completed)
                  .length,
            ),
          ],
        ),
      ),
    );
  }
}

void openDetail(BuildContext context, Coffee coffee) {
  // A leftover toast would sit on top of the detail page's purchase bar.
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DetailPage(coffee: coffee)),
  );
}

void quickAdd(BuildContext context, Coffee coffee) =>
    addToBasketWithFeedback(context, coffee);

const _pagePadding = EdgeInsets.symmetric(horizontal: 24);
const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 240,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 0.66,
);

String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour < 5) return 'Good night';
  if (hour < 11) return 'Good morning';
  if (hour < 15) return 'Good afternoon';
  if (hour < 22) return 'Good evening';
  return 'Good night';
}

class _MenuTab extends StatefulWidget {
  const _MenuTab();

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  final _search = TextEditingController();
  CoffeeCategory? _category;
  MenuSort _sort = MenuSort.recommended;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _resetFilters() => setState(() {
    _search.clear();
    _category = null;
    _sort = MenuSort.recommended;
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final query = _search.text.trim();
    final results = queryMenu(
      coffeeMenu,
      query: query,
      category: _category,
      sort: _sort,
    );
    final featured = coffeeMenu.firstWhere((c) => c.featured);
    final browsing = query.isEmpty && _category == null;
    final lastOrder = state.orders.isEmpty ? null : state.orders.first;

    return SafeArea(
      bottom: false,
      child: PageFrame(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: _pagePadding.copyWith(top: 20),
              sliver: SliverList.list(
                children: [
                  FadeSlideIn(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${greetingFor(DateTime.now())}, ${state.userName}',
                                style: AppText.body(14, color: AppColors.muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'What are we\nbrewing today?',
                                style: AppText.display(30),
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: 'Account',
                          child: Pressable(
                            semanticLabel: 'Account',
                            scale: 0.9,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountPage(),
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.copperSoft,
                              child: Text(
                                state.userName.isEmpty
                                    ? '?'
                                    : state.userName.characters.first,
                                style: AppText.display(
                                  20,
                                  color: AppColors.copperDeep,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      style: AppText.body(15, weight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Search drinks or ingredients',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => setState(_search.clear),
                              ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: AppMotion.medium,
                    curve: AppMotion.curve,
                    alignment: Alignment.topCenter,
                    child: browsing
                        ? Column(
                            children: [
                              if (lastOrder != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: FadeSlideIn(
                                    delay: const Duration(milliseconds: 90),
                                    child: _OrderAgainCard(order: lastOrder),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: FadeSlideIn(
                                  delay: const Duration(milliseconds: 120),
                                  child: _FeaturedCard(coffee: featured),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  padding: _pagePadding,
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'All',
                      selected: _category == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    for (final category in CoffeeCategory.values)
                      _CategoryChip(
                        label: category.label,
                        selected: _category == category,
                        onTap: () => setState(
                          () => _category = _category == category
                              ? null
                              : category,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: _pagePadding.copyWith(top: 20, bottom: 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            browsing
                                ? 'Our menu'
                                : (_category?.label ?? 'Results'),
                            style: AppText.display(22),
                          ),
                          Text(
                            '${results.length} ${results.length == 1 ? 'drink' : 'drinks'}',
                            style: AppText.body(13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    _SortButton(
                      value: _sort,
                      onChanged: (s) => setState(() => _sort = s),
                    ),
                  ],
                ),
              ),
            ),
            if (results.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No matches',
                  message: query.isEmpty
                      ? 'Nothing in this category yet.'
                      : 'Nothing matches “$query”. Try a drink name or an ingredient like “milk”.',
                  actionLabel: 'Clear filters',
                  onAction: _resetFilters,
                ),
              )
            else
              SliverPadding(
                padding: _pagePadding,
                sliver: SliverGrid.builder(
                  gridDelegate: _gridDelegate,
                  itemCount: results.length,
                  itemBuilder: (context, i) => FadeSlideIn(
                    key: ValueKey(results[i].id),
                    delay: Duration(milliseconds: 40 * (i % 6)),
                    child: CoffeeCard(
                      coffee: results[i],
                      onOpen: () => openDetail(context, results[i]),
                      onQuickAdd: () => quickAdd(context, results[i]),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: navBarClearance(context) + 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

  final MenuSort value;
  final ValueChanged<MenuSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value != MenuSort.recommended;
    return PopupMenuButton<MenuSort>(
      tooltip: 'Sort drinks',
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      itemBuilder: (_) => [
        for (final sort in MenuSort.values)
          PopupMenuItem(
            value: sort,
            child: Row(
              children: [
                Expanded(child: Text(sort.label, style: AppText.body(14))),
                if (sort == value)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.copper,
                  ),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: AppMotion.medium,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.copperSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? AppColors.copper : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.ink),
            const SizedBox(width: 6),
            Text(
              active ? value.label.split(':').first : 'Sort',
              style: AppText.body(13, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.espresso : AppColors.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? AppColors.espresso : AppColors.line,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.medium,
            style: AppText.body(
              13,
              weight: FontWeight.w600,
              color: selected ? AppColors.cream : AppColors.ink,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// One-tap repeat of the most recent order: the most common coffee habit.
class _OrderAgainCard extends StatelessWidget {
  const _OrderAgainCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final first = coffeeById(order.lines.first.coffeeId);
    final summary = order.lines
        .map((l) => '${l.quantity}× ${l.name}')
        .join(', ');
    return Pressable(
      onTap: () => reorderWithFeedback(context, order),
      scale: 0.98,
      semanticLabel: 'Order again: $summary',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            if (first != null) ...[
              CoffeeArt(coffee: first, size: 48, hero: false),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER AGAIN',
                    style: AppText.overline(color: AppColors.copperDeep),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(14, weight: FontWeight.w600),
                  ),
                  Text(
                    formatRupiah(order.subtotal),
                    style: AppText.body(12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.espresso,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.replay_rounded,
                color: AppColors.cream,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.coffee});

  final Coffee coffee;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => openDetail(context, coffee),
      scale: 0.98,
      semanticLabel: 'Featured: ${coffee.name}',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.espresso,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.lifted,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              bottom: -40,
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.copper.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEEKLY SIGNATURE', style: AppText.overline()),
                        const SizedBox(height: 10),
                        Text(
                          coffee.name,
                          style: AppText.display(24, color: AppColors.cream),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          coffee.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            13,
                            color: AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formatRupiah(coffee.price),
                          style: AppText.body(
                            16,
                            weight: FontWeight.w700,
                            color: AppColors.copperSoft,
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Order now',
                          variant: AppButtonVariant.accent,
                          expand: false,
                          onPressed: () => quickAdd(context, coffee),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  CoffeeArt(coffee: coffee, size: 110, hero: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final favorites = state.favorites;
    return SafeArea(
      bottom: false,
      child: PageFrame(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: _pagePadding.copyWith(top: 20, bottom: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved', style: AppText.display(30)),
                    const SizedBox(height: 4),
                    Text(
                      'Drinks you\'ve marked with a heart.',
                      style: AppText.body(14, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            if (favorites.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Nothing saved yet',
                  message:
                      'Tap the heart on any drink to keep it here for later.',
                  actionLabel: 'Browse the menu',
                  onAction: () => state.selectTab(HomeTabs.menu),
                ),
              )
            else
              SliverPadding(
                padding: _pagePadding,
                sliver: SliverGrid.builder(
                  gridDelegate: _gridDelegate,
                  itemCount: favorites.length,
                  itemBuilder: (context, i) => CoffeeCard(
                    key: ValueKey(favorites[i].id),
                    coffee: favorites[i],
                    hero: false,
                    onOpen: () => openDetail(context, favorites[i]),
                    onQuickAdd: () => quickAdd(context, favorites[i]),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: navBarClearance(context) + 24),
            ),
          ],
        ),
      ),
    );
  }
}
