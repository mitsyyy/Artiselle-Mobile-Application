import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.subtotal);

  CartItem? getItem(String productId) {
    try { return _items.firstWhere((i) => i.product.id == productId); }
    catch (_) { return null; }
  }

  /// Returns a message if capped, null otherwise.
  String? addToCart(ProductModel product, {int quantity = 1}) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final current = _items[idx].quantity;
      final capped = (current + quantity).clamp(1, product.stock);
      _items[idx] = _items[idx].copyWith(quantity: capped);
      notifyListeners();
      if (current + quantity > product.stock) {
        return 'Quantity capped at available stock (${product.stock}).';
      }
    } else {
      _items.add(CartItem(product: product, quantity: quantity.clamp(1, product.stock)));
      notifyListeners();
    }
    return null;
  }

  String? updateQuantity(String productId, int quantity) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return null;
    final stock = _items[idx].product.stock;
    final capped = quantity.clamp(1, stock);
    _items[idx] = _items[idx].copyWith(quantity: capped);
    notifyListeners();
    if (quantity > stock) return 'Quantity capped at available stock ($stock).';
    return null;
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
