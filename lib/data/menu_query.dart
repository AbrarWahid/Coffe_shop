import 'coffee.dart';

enum MenuSort {
  recommended('Recommended'),
  rating('Top rated'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low');

  const MenuSort(this.label);
  final String label;
}

/// Filters and sorts the menu. Search matches name, tagline, category and
/// ingredients, and every word must match (e.g. "iced milk").
List<Coffee> queryMenu(
  List<Coffee> menu, {
  String query = '',
  CoffeeCategory? category,
  MenuSort sort = MenuSort.recommended,
}) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty);
  bool matches(Coffee c) {
    final haystack = [
      c.name,
      c.tagline,
      c.category.label,
      ...c.ingredients,
    ].join(' ').toLowerCase();
    return terms.every(haystack.contains);
  }

  final results = menu
      .where((c) => category == null || c.category == category)
      .where(matches)
      .toList();
  switch (sort) {
    case MenuSort.recommended:
      break; // Curated menu order.
    case MenuSort.rating:
      results.sort((a, b) => b.rating.compareTo(a.rating));
    case MenuSort.priceLow:
      results.sort((a, b) => a.price.compareTo(b.price));
    case MenuSort.priceHigh:
      results.sort((a, b) => b.price.compareTo(a.price));
  }
  return results;
}
