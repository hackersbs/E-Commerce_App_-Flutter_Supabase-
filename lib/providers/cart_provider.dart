import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  double get totalPrice =>
      _items.fold(0, (total, product) => total + product.price);

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
