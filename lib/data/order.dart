import 'coffee.dart';

enum Fulfilment {
  delivery('Delivery', 'Brought to your door'),
  pickup('Pickup', 'Collect at the counter, no fee');

  const Fulfilment(this.label, this.caption);
  final String label;
  final String caption;
}

/// Payment is collected on delivery/pickup; there is no online payment yet,
/// so we only offer methods that genuinely work offline.
enum PaymentMethod {
  cash('Cash'),
  qris('QRIS');

  const PaymentMethod(this.label);
  final String label;
}

enum OrderStatus {
  received('Order received'),
  brewing('Brewing'),
  onTheWay('On the way'),
  ready('Ready for pickup'),
  completed('Completed');

  const OrderStatus(this.label);
  final String label;
}

/// Pricing rules in one place so basket, checkout and history agree.
abstract final class Pricing {
  static const deliveryFee = 10000;
  static const freeDeliveryThreshold = 100000;

  static int deliveryFor(int subtotal, Fulfilment fulfilment) =>
      fulfilment == Fulfilment.pickup || subtotal >= freeDeliveryThreshold
      ? 0
      : deliveryFee;
}

/// Snapshot of a purchased item. Name and price are copied so history stays
/// correct even if the menu changes later.
class OrderLine {
  const OrderLine({
    required this.coffeeId,
    required this.name,
    required this.size,
    required this.quantity,
    required this.unitPrice,
  });

  final String coffeeId;
  final String name;
  final CupSize size;
  final int quantity;
  final int unitPrice;

  int get total => unitPrice * quantity;

  Map<String, Object?> toJson() => {
    'coffeeId': coffeeId,
    'name': name,
    'size': size.name,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  factory OrderLine.fromJson(Map<String, Object?> json) => OrderLine(
    coffeeId: json['coffeeId'] as String,
    name: json['name'] as String,
    size: CupSize.values.byName(json['size'] as String),
    quantity: json['quantity'] as int,
    unitPrice: json['unitPrice'] as int,
  );
}

class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.fulfilment,
    required this.payment,
    required this.deliveryFee,
    this.address,
    this.phone,
    this.note,
  });

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final Fulfilment fulfilment;
  final PaymentMethod payment;
  final int deliveryFee;
  final String? address;
  final String? phone;
  final String? note;

  int get subtotal => lines.fold(0, (sum, l) => sum + l.total);
  int get total => subtotal + deliveryFee;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  /// Simulated progress until a real order backend reports status.
  OrderStatus statusAt(DateTime now) {
    final minutes = now.difference(placedAt).inSeconds / 60;
    if (minutes < 2) return OrderStatus.received;
    if (minutes < 8) return OrderStatus.brewing;
    if (minutes < 25) {
      return fulfilment == Fulfilment.delivery
          ? OrderStatus.onTheWay
          : OrderStatus.ready;
    }
    return OrderStatus.completed;
  }

  /// Ordered steps shown in the tracker for this fulfilment type.
  List<OrderStatus> get steps => [
    OrderStatus.received,
    OrderStatus.brewing,
    fulfilment == Fulfilment.delivery
        ? OrderStatus.onTheWay
        : OrderStatus.ready,
    OrderStatus.completed,
  ];

  Map<String, Object?> toJson() => {
    'id': id,
    'placedAt': placedAt.toIso8601String(),
    'lines': [for (final l in lines) l.toJson()],
    'fulfilment': fulfilment.name,
    'payment': payment.name,
    'deliveryFee': deliveryFee,
    'address': address,
    'phone': phone,
    'note': note,
  };

  factory Order.fromJson(Map<String, Object?> json) => Order(
    id: json['id'] as String,
    placedAt: DateTime.parse(json['placedAt'] as String),
    lines: [
      for (final l in json['lines'] as List)
        OrderLine.fromJson((l as Map).cast()),
    ],
    fulfilment: Fulfilment.values.byName(json['fulfilment'] as String),
    payment: PaymentMethod.values.byName(json['payment'] as String),
    deliveryFee: json['deliveryFee'] as int,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    note: json['note'] as String?,
  );
}

/// Delivery details remembered for the next checkout.
class DeliveryProfile {
  const DeliveryProfile({this.address = '', this.phone = ''});

  final String address;
  final String phone;

  bool get isEmpty => address.isEmpty && phone.isEmpty;

  Map<String, Object?> toJson() => {'address': address, 'phone': phone};

  factory DeliveryProfile.fromJson(Map<String, Object?> json) =>
      DeliveryProfile(
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}
