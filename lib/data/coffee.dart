import 'package:flutter/material.dart';

enum CoffeeCategory {
  espresso('Espresso'),
  milk('Milk based'),
  cold('Cold'),
  signature('Signature');

  const CoffeeCategory(this.label);
  final String label;
}

enum CupSize {
  small('S', 'Small', -5000),
  regular('M', 'Regular', 0),
  large('L', 'Large', 7000);

  const CupSize(this.short, this.label, this.priceDelta);
  final String short;
  final String label;
  final int priceDelta;
}

class Coffee {
  const Coffee({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.category,
    required this.tone,
    this.rating = 4.7,
    this.featured = false,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> ingredients;
  final int price;
  final CoffeeCategory category;

  /// Accent colour used for the product artwork background.
  final Color tone;
  final double rating;
  final bool featured;

  int priceFor(CupSize size) => price + size.priceDelta;
}

Coffee? coffeeById(String id) {
  for (final c in coffeeMenu) {
    if (c.id == id) return c;
  }
  return null;
}

const coffeeMenu = <Coffee>[
  Coffee(
    id: 'caramel-macchiato',
    name: 'Caramel Macchiato',
    tagline: 'Velvety & sweet',
    description: 'Freshly steamed milk marked with a double shot of espresso and finished with a buttery caramel drizzle.',
    ingredients: [
      'Arabica espresso',
      'Steamed milk',
      'Vanilla syrup',
      'Caramel',
    ],
    price: 35000,
    category: CoffeeCategory.signature,
    tone: Color(0xFFD9A36E),
    rating: 4.9,
    featured: true,
  ),
  Coffee(
    id: 'vanilla-latte',
    name: 'Vanilla Latte',
    tagline: 'Smooth & mellow',
    description: 'A comforting latte with Madagascar vanilla, balanced with our house espresso blend.',
    ingredients: ['Arabica espresso', 'Steamed milk', 'Vanilla bean syrup'],
    price: 30000,
    category: CoffeeCategory.milk,
    tone: Color(0xFFE6C9A0),
    rating: 4.8,
  ),
  Coffee(
    id: 'espresso-arabica',
    name: 'Espresso Arabica',
    tagline: 'Bold & bright',
    description: 'A concentrated shot of single-origin Gayo Arabica with notes of dark chocolate and citrus.',
    ingredients: ['Gayo Arabica beans'],
    price: 25000,
    category: CoffeeCategory.espresso,
    tone: Color(0xFF8C5A3C),
    rating: 4.7,
  ),
  Coffee(
    id: 'cappuccino',
    name: 'Cappuccino',
    tagline: 'Classic foam',
    description: 'Equal parts espresso, steamed milk and a thick cloud of microfoam, dusted with cocoa.',
    ingredients: ['Arabica espresso', 'Steamed milk', 'Milk foam', 'Cocoa'],
    price: 32000,
    category: CoffeeCategory.milk,
    tone: Color(0xFFC89B7B),
    rating: 4.8,
  ),
  Coffee(
    id: 'americano',
    name: 'Americano',
    tagline: 'Clean & light',
    description: 'A double espresso lengthened with hot water for a clean, easy-drinking cup.',
    ingredients: ['Arabica espresso', 'Hot water'],
    price: 24000,
    category: CoffeeCategory.espresso,
    tone: Color(0xFF6E4630),
    rating: 4.6,
  ),
  Coffee(
    id: 'cold-brew',
    name: 'Cold Brew',
    tagline: 'Slow steeped, 18h',
    description: 'Steeped for eighteen hours for a naturally sweet, low-acid coffee served over ice.',
    ingredients: ['Cold-steeped Arabica', 'Ice'],
    price: 33000,
    category: CoffeeCategory.cold,
    tone: Color(0xFF5B3A29),
    rating: 4.8,
  ),
  Coffee(
    id: 'es-kopi-susu',
    name: 'Es Kopi Susu',
    tagline: 'Palm sugar & milk',
    description: 'Our take on the Indonesian favourite: espresso, fresh milk and gula aren over ice.',
    ingredients: ['Arabica espresso', 'Fresh milk', 'Gula aren', 'Ice'],
    price: 28000,
    category: CoffeeCategory.cold,
    tone: Color(0xFFCFA27E),
    rating: 4.9,
  ),
  Coffee(
    id: 'flat-white',
    name: 'Flat White',
    tagline: 'Silky microfoam',
    description: 'A ristretto double shot under a thin layer of glossy microfoam for a strong, smooth cup.',
    ingredients: ['Ristretto espresso', 'Microfoam milk'],
    price: 31000,
    category: CoffeeCategory.milk,
    tone: Color(0xFFB98A68),
    rating: 4.7,
  ),
];
