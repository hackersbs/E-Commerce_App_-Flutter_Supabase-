import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Product> _items = const [];
  String? _cartId;
  String? _lastError;

  List<Product> get items => List.unmodifiable(_items);
  List<Product> get uniqueItems =>
      _items.fold<List<Product>>([], (result, product) {
        if (!result.any((item) => item.id == product.id)) result.add(product);
        return result;
      });
  String? get lastError => _lastError;
  double get totalPrice =>
      _items.fold(0, (total, product) => total + product.price);

  int quantityFor(Product product) =>
      _items.where((item) => item.id == product.id).length;

  Future<void> loadCart() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final cart = await _supabase
          .from('carts')
          .select('id')
          .eq('buyer_id', userId)
          .maybeSingle();
      if (cart == null) {
        _cartId = null;
        _items = const [];
        notifyListeners();
        return;
      }
      _cartId = cart['id'] as String;
      final rows = await _supabase
          .from('cart_items')
          .select(
            'quantity, product:products(*, seller:profiles!products_seller_id_fkey(username))',
          )
          .eq('cart_id', _cartId!);
      _items = (rows as List).expand<Product>((row) {
        final data = Map<String, dynamic>.from(row as Map);
        final product = Product.fromMap(
          Map<String, dynamic>.from(data['product'] as Map),
        );
        return List<Product>.filled((data['quantity'] as num).toInt(), product);
      }).toList();
    } on PostgrestException catch (error) {
      _lastError = error.message;
    }
    notifyListeners();
  }

  Future<bool> add(Product product) async {
    _lastError = null;
    try {
      await _supabase.rpc('add_to_cart', params: {'p_product_id': product.id});
      await loadCart();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  Future<bool> remove(Product product) async {
    _lastError = null;
    try {
      await _supabase.rpc(
        'remove_from_cart',
        params: {'p_product_id': product.id},
      );
      await loadCart();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  Future<String?> checkout() async {
    try {
      final result = await _supabase.rpc('place_order');
      await loadCart();
      return result as String?;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return null;
    }
  }
}
