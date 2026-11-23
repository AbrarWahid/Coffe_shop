import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/auth_repository.dart';
import '../data/coffee.dart';
import '../data/local_store.dart';
import '../data/order.dart';

class CartLine {
  const CartLine({
    required this.coffee,
    required this.size,
    required this.quantity,
  });

  final Coffee coffee;
  final CupSize size;
  final int quantity;

  String get key => '${coffee.id}:${size.name}';
  int get unitPrice => coffee.priceFor(size);
  int get total => unitPrice * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(coffee: coffee, size: size, quantity: quantity ?? this.quantity);

  Map<String, Object?> toJson() => {
    'coffeeId': coffee.id,
    'size': size.name,
    'quantity': quantity,
  };

  static CartLine? fromJson(Map<String, Object?> json) {
    final coffee = coffeeById(json['coffeeId'] as String? ?? '');
    if (coffee == null) return null; // Item was removed from the menu.
    return CartLine(
      coffee: coffee,
      size: CupSize.values.asNameMap()[json['size']] ?? CupSize.regular,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

/// Checkout input collected by the checkout sheet.
class CheckoutDetails {
  const CheckoutDetails({
    required this.fulfilment,
    required this.payment,
    this.address,
    this.phone,
    this.note,
    this.remember = true,
  });

  final Fulfilment fulfilment;
  final PaymentMethod payment;
  final String? address;
  final String? phone;
  final String? note;
  final bool remember;
}

/// App-wide state: session, basket, favourites, orders and the home tab.
/// Everything except the tab is persisted per user on the device.
class AppState extends ChangeNotifier {
  AppState({this.latency = const Duration(milliseconds: 700)});

  static const maxQuantity = 20;

  /// Simulated network latency for auth and ordering.
  final Duration latency;

  late final LocalStore _store;
  late final AuthRepository _auth;

  bool _ready = false;
  Account? _account;
  final Map<String, CartLine> _cart = {};
  final Set<String> _favorites = {};
  final List<Order> _orders = [];
  DeliveryProfile _profile = const DeliveryProfile();
  int _tab = 0;

  bool get ready => _ready;
  Account? get account => _account;
  String get userName => _account?.displayName ?? '';

  List<CartLine> get cart => List.unmodifiable(_cart.values);
  int get itemCount => _cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => _cart.values.fold(0, (sum, line) => sum + line.total);
  int deliveryFor(Fulfilment f) =>
      _cart.isEmpty ? 0 : Pricing.deliveryFor(subtotal, f);
  int totalFor(Fulfilment f) => subtotal + deliveryFor(f);

  /// Remaining spend to unlock free delivery, or 0 if already unlocked.
  int get untilFreeDelivery => (Pricing.freeDeliveryThreshold - subtotal).clamp(
    0,
    Pricing.freeDeliveryThreshold,
  );

  List<Order> get orders => List.unmodifiable(_orders);
  DeliveryProfile get deliveryProfile => _profile;
  int get tab => _tab;

  bool isFavorite(Coffee coffee) => _favorites.contains(coffee.id);
  List<Coffee> get favorites =>
      coffeeMenu.where((c) => _favorites.contains(c.id)).toList();

  // ---------------------------------------------------------------- session

  Future<void> init({LocalStore? store}) async {
    _store = store ?? await LocalStore.open();
    _auth = AuthRepository(_store);
    final session = _auth.currentSession();
    if (session != null) _activate(session);
    _ready = true;
    notifyListeners();
  }

  Future<void> signIn(String username, String password) async {
    await Future<void>.delayed(latency);
    _activate(await _auth.signIn(username: username, password: password));
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    await Future<void>.delayed(latency);
    _activate(
      await _auth.register(
        username: username,
        email: email,
        password: password,
      ),
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _account = null;
    _clearUserData();
    notifyListeners();
  }

  void _activate(Account account) {
    _account = account;
    _clearUserData();
    final data = _store.readJson(_userKey) ?? const {};
    for (final raw in (data['cart'] as List? ?? const [])) {
      final line = CartLine.fromJson((raw as Map).cast());
      if (line != null) _cart[line.key] = line;
    }
    _favorites.addAll((data['favorites'] as List? ?? const []).cast<String>());
    for (final raw in (data['orders'] as List? ?? const [])) {
      try {
        _orders.add(Order.fromJson((raw as Map).cast()));
      } on Object {
        // Skip records written by an incompatible version.
      }
    }
    final profile = data['profile'];
    if (profile is Map) _profile = DeliveryProfile.fromJson(profile.cast());
  }

  void _clearUserData() {
    _cart.clear();
    _favorites.clear();
    _orders.clear();
    _profile = const DeliveryProfile();
    _tab = 0;
  }

  String get _userKey => 'user.${_account!.username}';

  void _changed() {
    notifyListeners();
    if (_account == null) return;
    unawaited(
      _store.writeJson(_userKey, {
        'cart': [for (final l in _cart.values) l.toJson()],
        'favorites': _favorites.toList(),
        'orders': [for (final o in _orders) o.toJson()],
        'profile': _profile.toJson(),
      }),
    );
  }

  // -------------------------------------------------------------- navigation

  void selectTab(int index) {
    if (_tab == index) return;
    _tab = index;
    notifyListeners();
  }

  // ------------------------------------------------------- favourites & cart

  void toggleFavorite(Coffee coffee) {
    if (!_favorites.remove(coffee.id)) _favorites.add(coffee.id);
    _changed();
  }

  /// Adds to the basket, capped at [maxQuantity] per line.
  /// Returns how many were actually added (0 if the line was already full).
  int add(Coffee coffee, {CupSize size = CupSize.regular, int quantity = 1}) {
    final line = CartLine(coffee: coffee, size: size, quantity: 0);
    final existing = _cart[line.key] ?? line;
    final next = (existing.quantity + quantity).clamp(0, maxQuantity);
    final added = next - existing.quantity;
    if (added > 0) {
      _cart[line.key] = existing.copyWith(quantity: next);
      _changed();
    }
    return added;
  }

  void setQuantity(CartLine line, int quantity) {
    if (quantity < 1) return remove(line);
    _cart[line.key] = line.copyWith(quantity: quantity.clamp(1, maxQuantity));
    _changed();
  }

  void remove(CartLine line) {
    _cart.remove(line.key);
    _changed();
  }

  void restore(CartLine line) {
    _cart[line.key] = line;
    _changed();
  }

  void clearCart() {
    _cart.clear();
    _changed();
  }

  // ------------------------------------------------------------------ orders

  Future<Order> placeOrder(CheckoutDetails details) async {
    if (_cart.isEmpty) throw StateError('Your basket is empty.');
    await Future<void>.delayed(latency);
    final delivery = details.fulfilment == Fulfilment.delivery;
    final order = Order(
      id: _orderId(),
      placedAt: DateTime.now(),
      lines: [
        for (final l in _cart.values)
          OrderLine(
            coffeeId: l.coffee.id,
            name: l.coffee.name,
            size: l.size,
            quantity: l.quantity,
            unitPrice: l.unitPrice,
          ),
      ],
      fulfilment: details.fulfilment,
      payment: details.payment,
      deliveryFee: deliveryFor(details.fulfilment),
      address: delivery ? details.address?.trim() : null,
      phone: details.phone?.trim(),
      note: (details.note?.trim().isEmpty ?? true)
          ? null
          : details.note!.trim(),
    );
    _orders.insert(0, order);
    if (details.remember) {
      _profile = DeliveryProfile(
        address: delivery ? order.address ?? '' : _profile.address,
        phone: order.phone ?? _profile.phone,
      );
    }
    _cart.clear();
    _changed();
    return order;
  }

  /// Puts an earlier order back into the basket. Returns the number of lines
  /// that could not be added because they are no longer on the menu.
  int reorder(Order order) {
    var unavailable = 0;
    for (final line in order.lines) {
      final coffee = coffeeById(line.coffeeId);
      if (coffee == null) {
        unavailable++;
        continue;
      }
      final l = CartLine(coffee: coffee, size: line.size, quantity: 0);
      final existing = _cart[l.key] ?? l;
      _cart[l.key] = existing.copyWith(
        quantity: (existing.quantity + line.quantity).clamp(1, maxQuantity),
      );
    }
    _changed();
    return unavailable;
  }

  void forgetDeliveryProfile() {
    _profile = const DeliveryProfile();
    _changed();
  }

  String _orderId() {
    final now = DateTime.now();
    final seq = (now.millisecondsSinceEpoch % 100000).toString().padLeft(
      5,
      '0',
    );
    return 'CS-${now.year % 100}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-$seq';
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// Reads the state and rebuilds [context] when it changes.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without subscribing (for callbacks).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
