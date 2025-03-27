import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, int> _cartItems = {};

  int get cartItemCount =>
      _cartItems.values.fold(0, (sum, quantity) => sum + quantity);

  void addItem(int id) {
    _cartItems[id] = (_cartItems[id] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(int id) {
    if (_cartItems.containsKey(id)) {
      if (_cartItems[id]! > 1) {
        _cartItems[id] = _cartItems[id]! - 1;
      } else {
        _cartItems.remove(id);
      }
      notifyListeners();
    }
  }

  void updateItem(int id, int quantity) {
    if (quantity > 0) {
      _cartItems[id] = quantity;
    } else {
      _cartItems.remove(id);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
