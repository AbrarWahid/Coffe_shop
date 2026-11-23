import 'package:coffe_shop/data/coffee.dart';
import 'package:coffe_shop/data/local_store.dart';
import 'package:coffe_shop/data/menu_query.dart';
import 'package:coffe_shop/data/order.dart';
import 'package:coffe_shop/main.dart';
import 'package:coffe_shop/state/app_state.dart';
import 'package:coffe_shop/utils/format.dart';
import 'package:coffe_shop/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> freshState() async {
  final state = AppState(latency: Duration.zero);
  await state.init(store: await LocalStore.open());
  return state;
}

void main() {
  // Tests run offline; fall back to the default font instead of fetching.
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final latte = coffeeById('vanilla-latte')!;
  final macchiato = coffeeById('caramel-macchiato')!;

  group('formatting & pricing', () {
    test('formatRupiah groups thousands with dots', () {
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(5000), 'Rp 5.000');
      expect(formatRupiah(1250000), 'Rp 1.250.000');
    });

    test('delivery is free for pickup and above the threshold', () {
      expect(
        Pricing.deliveryFor(50000, Fulfilment.delivery),
        Pricing.deliveryFee,
      );
      expect(Pricing.deliveryFor(50000, Fulfilment.pickup), 0);
      expect(
        Pricing.deliveryFor(Pricing.freeDeliveryThreshold, Fulfilment.delivery),
        0,
      );
    });
  });

  group('menu query', () {
    test('search matches ingredients and requires every word', () {
      final names = queryMenu(coffeeMenu, query: 'gula ice').map((c) => c.name);
      expect(names, ['Es Kopi Susu']);
      expect(queryMenu(coffeeMenu, query: 'milk').length, greaterThan(3));
    });

    test('sorts by price and rating', () {
      final byPrice = queryMenu(
        coffeeMenu,
        sort: MenuSort.priceLow,
      ).map((c) => c.price).toList();
      expect(byPrice, [...byPrice]..sort());
      final byRating = queryMenu(coffeeMenu, sort: MenuSort.rating);
      expect(byRating.first.rating, 4.9);
    });
  });

  group('validators', () {
    test('Indonesian mobile numbers', () {
      expect(Validators.phone('0812 3456 7890'), isNull);
      expect(Validators.phone('+6281234567890'), isNull);
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('0212345678'), isNotNull); // landline
    });

    test('new passwords need 8+ chars with letters and a number', () {
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('longpassword'), isNotNull);
      expect(Validators.newPassword('coffee123'), isNull);
    });
  });

  group('auth', () {
    test(
      'register signs in; duplicates and wrong passwords are rejected',
      () async {
        final state = await freshState();
        await state.register('Tony', 'tony@example.com', 'coffee123');
        expect(state.userName, 'Tony');
        await expectLater(
          state.register('tony', 'x@example.com', 'coffee123'),
          throwsException,
        );

        await state.signOut();
        expect(state.account, isNull);
        await expectLater(state.signIn('tony', 'wrong'), throwsException);
        await expectLater(state.signIn('nobody', 'coffee123'), throwsException);
        await state.signIn(' TONY ', 'coffee123');
        expect(state.account?.username, 'tony');
      },
    );
  });

  group('basket & orders', () {
    test('caps each line at the maximum and reports what was added', () async {
      final state = await freshState();
      await state.register('tony', 'tony@example.com', 'coffee123');
      expect(state.add(latte, quantity: 15), 15);
      expect(state.add(latte, quantity: 10), AppState.maxQuantity - 15);
      expect(state.add(latte), 0);
      expect(state.add(latte, size: CupSize.large), 1);
    });

    test(
      'placing an order records it, remembers details and clears the basket',
      () async {
        final state = await freshState();
        await state.register('tony', 'tony@example.com', 'coffee123');
        state.add(latte, quantity: 2);
        final order = await state.placeOrder(
          const CheckoutDetails(
            fulfilment: Fulfilment.delivery,
            payment: PaymentMethod.qris,
            address: 'Jl. Braga 12, Bandung',
            phone: '081234567890',
            note: '  ',
          ),
        );
        expect(order.total, 60000 + Pricing.deliveryFee);
        expect(order.note, isNull);
        expect(state.cart, isEmpty);
        expect(state.orders.single.id, order.id);
        expect(state.deliveryProfile.address, 'Jl. Braga 12, Bandung');

        expect(state.reorder(order), 0);
        expect(state.itemCount, 2);
      },
    );

    test('empty basket cannot be ordered', () async {
      final state = await freshState();
      await state.register('tony', 'tony@example.com', 'coffee123');
      await expectLater(
        state.placeOrder(
          const CheckoutDetails(
            fulfilment: Fulfilment.pickup,
            payment: PaymentMethod.cash,
          ),
        ),
        throwsStateError,
      );
    });

    test('session and per-user data survive a restart', () async {
      final first = await freshState();
      await first.register('tony', 'tony@example.com', 'coffee123');
      first
        ..add(macchiato, quantity: 3)
        ..toggleFavorite(latte);
      await Future<void>.delayed(Duration.zero); // let writes flush

      final second = await freshState();
      expect(second.account?.username, 'tony');
      expect(second.itemCount, 3);
      expect(second.isFavorite(latte), isTrue);

      // Another user on the same device starts clean.
      await second.signOut();
      await second.register('rina', 'rina@example.com', 'coffee123');
      expect(second.itemCount, 0);
      expect(second.favorites, isEmpty);
    });

    test('order status advances with time', () {
      final placed = DateTime(2026, 1, 1, 8);
      final order = Order(
        id: 'x',
        placedAt: placed,
        lines: const [],
        fulfilment: Fulfilment.pickup,
        payment: PaymentMethod.cash,
        deliveryFee: 0,
      );
      expect(order.statusAt(placed), OrderStatus.received);
      expect(
        order.statusAt(placed.add(const Duration(minutes: 5))),
        OrderStatus.brewing,
      );
      expect(
        order.statusAt(placed.add(const Duration(minutes: 10))),
        OrderStatus.ready,
      );
      expect(
        order.statusAt(placed.add(const Duration(hours: 1))),
        OrderStatus.completed,
      );
    });
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    // Lazily built lists may not contain the target yet on small screens.
    if (find.text(text).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.text(text),
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .last,
      );
    }
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String label, String value) async {
    final field = find.descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(Column))
          .first,
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    // Let the focused field finish scrolling itself into view.
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 640), Size(390, 844), Size(1280, 800)]) {
    testWidgets('register, order, track, sign out and back in at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MyApp(state: AppState(latency: Duration.zero)));
      await tester.pumpAndSettle();

      // Unknown account gives a clear, inline error.
      await fill(tester, 'Username', 'tony');
      await fill(tester, 'Password', 'coffee123');
      await tapText(tester, 'Sign in');
      expect(find.text('No account found with that username.'), findsOneWidget);

      // Registering signs straight in.
      await tapText(tester, 'Create an account');
      await tapText(tester, 'Create account');
      expect(find.text('Please enter your username'), findsOneWidget);
      await fill(tester, 'Username', 'tony');
      await fill(tester, 'Email', 'tony@example.com');
      await fill(tester, 'Password', 'coffee123');
      await tapText(tester, 'Create account');
      expect(find.text('What are we\nbrewing today?'), findsOneWidget);
      expect(find.textContaining(', Tony'), findsOneWidget);

      // Detail -> large x2 -> add.
      await tapText(tester, 'Vanilla Latte');
      await tapText(tester, 'Large');
      await tester.tap(find.bySemanticsLabel('Increase quantity'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 74.000'), findsOneWidget);
      await tapText(tester, 'Add to basket');
      expect(
        find.textContaining('2× Vanilla Latte (Large) added'),
        findsOneWidget,
      );

      // Basket shows the free-delivery nudge, then checkout.
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Add Rp 26.000 more for free delivery'), findsOneWidget);
      await tapText(tester, 'Checkout');
      await tapText(tester, 'Place order');
      expect(find.text('Please check the highlighted fields.'), findsOneWidget);
      expect(find.text('Please enter your delivery address'), findsOneWidget);

      // Pickup hides the address and drops the fee.
      await tapText(tester, 'Pickup');
      expect(find.text('Delivery address'), findsNothing);
      await fill(tester, 'Phone, in case we need you', '0812 3456 7890');
      await tapText(tester, 'Place order');
      expect(find.text('Order placed'), findsOneWidget);

      // Track order opens the order detail with its status.
      await tapText(tester, 'Track order');
      expect(find.text('Order received'), findsWidgets);
      expect(find.text('Collect at the counter'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('In progress'), findsOneWidget);

      // Sign out from the account page, then back in: history is kept.
      await tester.tap(find.byIcon(Icons.local_cafe_outlined));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byTooltip('Account'),
        -300,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      await tester.tap(find.byTooltip('Account'));
      await tester.pumpAndSettle();
      expect(find.text('tony@example.com'), findsOneWidget);
      await tapText(tester, 'Sign out');
      await tapText(tester, 'Sign out');
      expect(
        find.text('Your daily ritual,\nbrewed with care.'),
        findsOneWidget,
      );

      await fill(tester, 'Username', 'tony');
      await fill(tester, 'Password', 'coffee123');
      await tapText(tester, 'Sign in');
      expect(find.text('ORDER AGAIN'), findsOneWidget);
    });
  }
}
